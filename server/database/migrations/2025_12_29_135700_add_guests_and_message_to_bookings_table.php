<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->integer('guests')->nullable()->after('check_out');
            $table->text('message')->nullable()->after('guests');
            
            // Update status enum to include 'approved' and 'rejected'
            // Need to modify the status column
            $table->enum('status', ['pending', 'approved', 'confirmed', 'rejected', 'cancelled', 'completed'])
                ->change();
        });
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn(['guests', 'message']);
            
            // Revert status enum to original values
            $table->enum('status', ['pending', 'confirmed', 'cancelled', 'completed'])
                ->change();
        });
    }
};
