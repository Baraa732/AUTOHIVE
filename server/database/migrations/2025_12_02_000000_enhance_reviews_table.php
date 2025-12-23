<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('reviews', function (Blueprint $table) {
            $table->unsignedBigInteger('booking_id')->nullable()->after('apartment_id');
            $table->tinyInteger('cleanliness_rating')->nullable()->after('rating');
            $table->tinyInteger('location_rating')->nullable()->after('cleanliness_rating');
            $table->tinyInteger('value_rating')->nullable()->after('location_rating');
            $table->tinyInteger('communication_rating')->nullable()->after('value_rating');
            
            $table->foreign('booking_id')->references('id')->on('bookings')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::table('reviews', function (Blueprint $table) {
            $table->dropForeign(['booking_id']);
            $table->dropColumn([
                'booking_id',
                'cleanliness_rating',
                'location_rating',
                'value_rating',
                'communication_rating'
            ]);
        });
    }
};