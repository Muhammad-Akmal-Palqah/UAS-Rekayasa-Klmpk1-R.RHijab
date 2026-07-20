<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Models\User;

class InitiatePaymentCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'payments:initiate {order_id} {--user_id=} {--email=} {--payment=gopay}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Initiate a payment for an order (DEMO_MODE friendly)';

    public function handle()
    {
        $orderId = $this->argument('order_id');
        $userId = $this->option('user_id');
        $email = $this->option('email');
        $paymentType = $this->option('payment');

        // Find user
        $user = null;
        if ($userId) {
            $user = User::find($userId);
        } elseif ($email) {
            $user = User::where('email', $email)->first();
        }

        if (!$user) {
            $this->error('User not found. Provide --user_id or --email');
            return 1;
        }

        // Check order in flutter DB
// Use default DB connection after unifying Flutter data into main database
        $order = DB::connection()->table('orders')->where('id_order', $orderId)->first();
        if (!$order) {
            $this->error('Order not found in flutter DB: ' . $orderId);
            return 1;
        }

        // Build a request and set user resolver
        $req = Request::create('/api/payments/initiate', 'POST', [
            'order_id' => $orderId,
            'payment_type' => $paymentType,
        ]);
        $req->setUserResolver(function () use ($user) {
            return $user;
        });

        try {
            $controller = app(\App\Http\Controllers\PaymentController::class);
            $response = $controller->initiate($req);

            if (method_exists($response, 'getContent')) {
                $this->info($response->getContent());
            } else {
                $this->info(json_encode($response));
            }

            return 0;
        } catch (\Exception $e) {
            $this->error('Error initiating payment: ' . $e->getMessage());
            return 1;
        }
    }
}

