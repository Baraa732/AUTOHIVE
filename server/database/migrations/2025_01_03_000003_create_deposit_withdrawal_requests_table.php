<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('deposit_withdrawal_requests', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->enum('type', ['deposit', 'withdrawal']);
            $table->unsignedBigInteger('amount_spy');
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->string('reason')->nullable();
            $table->unsignedBigInteger('approved_by')->nullable();
            $table->timestamp('approved_at')->nullable();
            $table->timestamps();
            
            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->onDelete('cascade');
            
            $table->foreign('approved_by')
                ->references('id')
                ->on('users')
                ->onDelete('set null');
            
            $table->index('user_id');
            $table->index('status');
            $table->index('created_at');
        });
    }

    public function down()
    {
        Schema::dropIfExists('deposit_withdrawal_requests');
    }
};
