<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// CLI helper to initiate a payment for demo/testing
Artisan::command('payments:initiate {order_id} {--user_id=} {--email=} {--payment=gopay}', function ($order_id) {
    $userId = $this->option('user_id');
    $email = $this->option('email');
    $paymentType = $this->option('payment');

    $this->line('Initiating payment for order: ' . $order_id . ' payment: ' . $paymentType);

    // Resolve user
    $user = null;
    if ($userId) {
        $user = \App\Models\User::find($userId);
    } elseif ($email) {
        $user = \App\Models\User::where('email', $email)->first();
    }

    if (!$user) {
        $this->error('User not found. Provide --user_id or --email');
        return 1;
    }

// Use default DB connection after unifying Flutter data into main database
    $order = \Illuminate\Support\Facades\DB::table('orders')->where('id_order', $order_id)->first();
    if (!$order) {
        $this->error('Order not found: ' . $order_id);
    }

    $req = \Illuminate\Http\Request::create('/api/payments/initiate', 'POST', [
        'order_id' => $order_id,
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
})->describe('Initiate a payment for an order (dev/demo)');

