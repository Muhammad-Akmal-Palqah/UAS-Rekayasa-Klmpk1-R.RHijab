<?php

namespace Tests\Unit;

use App\Models\FlutterProduct;
use App\Models\Product;
use Tests\TestCase;

class ProductConnectionTest extends TestCase
{
    public function test_web_admin_product_model_uses_default_connection_not_flutter(): void
    {
        $product = new Product();

        $this->assertNotSame('flutter', $product->getConnectionName());
    }

    public function test_flutter_admin_product_model_uses_default_database_connection(): void
    {
        $product = new FlutterProduct();

        $this->assertNotSame('flutter', $product->getConnectionName());
    }
}
