<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->enum('rental_status', ['active', 'inactive', 'pending'])->default('pending')->after('status');
            $table->date('rental_end_date')->nullable()->after('rental_status');
            
            $table->index('rental_status');
            $table->index('rental_end_date');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['rental_status', 'rental_end_date']);
        });
    }
};
