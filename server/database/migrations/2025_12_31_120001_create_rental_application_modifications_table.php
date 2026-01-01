<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rental_application_modifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('rental_application_id')->constrained('rental_applications')->onDelete('cascade');
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->json('previous_values');
            $table->json('new_values');
            $table->text('modification_reason')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->timestamp('submitted_at')->useCurrent();
            $table->timestamp('responded_at')->nullable();
            $table->timestamps();
            
            $table->index('rental_application_id');
            $table->index('status');
            $table->index('submitted_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rental_application_modifications');
    }
};
