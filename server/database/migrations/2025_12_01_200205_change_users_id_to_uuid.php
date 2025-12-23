<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        // Disable foreign key checks
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        
        // Drop foreign key constraints
        Schema::table('apartments', function (Blueprint $table) {
            $table->dropForeign(['landlord_id']);
        });
        
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropForeign(['tenant_id']);
        });
        
        Schema::table('reviews', function (Blueprint $table) {
            $table->dropForeign(['tenant_id']);
        });
        
        Schema::table('favorites', function (Blueprint $table) {
            $table->dropForeign(['tenant_id']);
        });
        
        Schema::table('notifications', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
        });
        
        // Change users table
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('id');
        });
        
        Schema::table('users', function (Blueprint $table) {
            $table->uuid('id')->primary()->first();
        });
        
        // Update related tables
        Schema::table('apartments', function (Blueprint $table) {
            $table->dropColumn('landlord_id');
        });
        
        Schema::table('apartments', function (Blueprint $table) {
            $table->uuid('landlord_id')->after('id');
        });
        
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn('tenant_id');
        });
        
        Schema::table('bookings', function (Blueprint $table) {
            $table->uuid('tenant_id')->after('id');
        });
        
        Schema::table('reviews', function (Blueprint $table) {
            $table->dropColumn('tenant_id');
        });
        
        Schema::table('reviews', function (Blueprint $table) {
            $table->uuid('tenant_id')->after('id');
        });
        
        Schema::table('favorites', function (Blueprint $table) {
            $table->dropColumn('tenant_id');
        });
        
        Schema::table('favorites', function (Blueprint $table) {
            $table->uuid('tenant_id')->after('id');
        });
        
        Schema::table('notifications', function (Blueprint $table) {
            $table->dropColumn('user_id');
        });
        
        Schema::table('notifications', function (Blueprint $table) {
            $table->uuid('user_id')->after('id');
        });
        
        Schema::table('activities', function (Blueprint $table) {
            $table->dropColumn('admin_id');
        });
        
        Schema::table('activities', function (Blueprint $table) {
            $table->uuid('admin_id')->after('id');
        });
        
        // Re-enable foreign key checks
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }

    public function down()
    {
        // Reverse the changes
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('id');
        });
        
        Schema::table('users', function (Blueprint $table) {
            $table->id()->first();
        });
        
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }
};