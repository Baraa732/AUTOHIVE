<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('wallet_transactions', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('wallet_id');
            $table->unsignedBigInteger('user_id');
            $table->enum('type', ['deposit', 'withdrawal', 'rental_payment', 'rental_received']);
            $table->unsignedBigInteger('amount_spy');
            $table->string('description')->nullable();
            $table->unsignedBigInteger('related_user_id')->nullable();
            $table->unsignedBigInteger('related_booking_id')->nullable();
            $table->timestamps();
            
            $table->foreign('wallet_id')
                ->references('id')
                ->on('wallets')
                ->onDelete('cascade');
            
            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->onDelete('cascade');
            
            $table->foreign('related_user_id')
                ->references('id')
                ->on('users')
                ->onDelete('set null');
            
            $table->foreign('related_booking_id')
                ->references('id')
                ->on('bookings')
                ->onDelete('set null');
            
            $table->index('wallet_id');
            $table->index('user_id');
            $table->index('created_at');
        });
    }

    public function down()
    {
        Schema::dropIfExists('wallet_transactions');
    }
};
