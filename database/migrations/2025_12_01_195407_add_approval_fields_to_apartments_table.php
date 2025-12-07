<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('apartments', function (Blueprint $table) {
            $table->boolean('is_approved')->default(false)->after('is_available');
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending')->after('is_approved');
            $table->text('rejection_reason')->nullable()->after('status');
        });
    }

    public function down()
    {
        Schema::table('apartments', function (Blueprint $table) {
            $table->dropColumn(['is_approved', 'status', 'rejection_reason']);
        });
    }
};