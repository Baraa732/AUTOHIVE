<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('bookings', function (Blueprint $table) {
            if (!Schema::hasColumn('bookings', 'booking_request_id')) {
                $table->foreignId('booking_request_id')
                    ->nullable()
                    ->constrained('booking_requests')
                    ->onDelete('set null')
                    ->after('id');
            }
        });
    }

    public function down()
    {
        Schema::table('bookings', function (Blueprint $table) {
            if (Schema::hasColumn('bookings', 'booking_request_id')) {
                $table->dropForeign(['booking_request_id']);
                $table->dropColumn('booking_request_id');
            }
        });
    }
};
