<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('apartments', function (Blueprint $table) {
            $table->integer('bedrooms')->default(1)->after('rooms');
            $table->integer('bathrooms')->default(1)->after('bedrooms');
            $table->decimal('area', 8, 2)->nullable()->after('bathrooms');
        });
    }

    public function down()
    {
        Schema::table('apartments', function (Blueprint $table) {
            $table->dropColumn(['bedrooms', 'bathrooms', 'area']);
        });
    }
};