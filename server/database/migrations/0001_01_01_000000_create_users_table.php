<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('phone')->unique();
            $table->string('password');
            $table->string('first_name');
            $table->string('last_name');
            $table->enum('role', ['user', 'admin'])->default('user');
            $table->string('profile_image')->nullable();
            $table->date('birth_date');
            $table->string('id_image')->nullable();
            $table->boolean('is_approved')->default(false);
            $table->enum('status', ['pending', 'approved', 'rejected', 'active', 'inactive', 'suspended'])->default('pending');
            $table->string('city')->nullable();
            $table->string('governorate')->nullable();
            $table->rememberToken();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down()
    {
        Schema::dropIfExists('users');
    }
};
