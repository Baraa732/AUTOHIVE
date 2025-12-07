@extends('admin.layout')

@section('title', 'Edit Apartment')
@section('icon', 'fas fa-edit')

@section('content')
<div class="content-card">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-edit"></i>
            Edit Apartment: {{ $apartment->title }}
        </h3>
    </div>
    
    <form method="POST" action="{{ route('admin.apartments.update', $apartment->id) }}" style="padding: var(--space-xl);">
        @csrf
        @method('PUT')
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: var(--space-lg);">
            <div>
                <label style="display: block; margin-bottom: var(--space-sm); font-weight: 600; color: var(--text-dark);">Title *</label>
                <input type="text" name="title" value="{{ old('title', $apartment->title) }}" required
                    style="width: 100%; padding: 12px; border: 1px solid var(--border-grey); border-radius: var(--radius-sm); font-size: 0.9rem;">
                @error('title')
                    <span style="color: #EF4444; font-size: 0.8rem;">{{ $message }}</span>
                @enderror
            </div>
            
            <div>
                <label style="display: block; margin-bottom: var(--space-sm); font-weight: 600; color: var(--text-dark);">Price Per Night *</label>
                <input type="number" name="price_per_night" value="{{ old('price_per_night', $apartment->price_per_night) }}" required step="0.01" min="0"
                    style="width: 100%; padding: 12px; border: 1px solid var(--border-grey); border-radius: var(--radius-sm); font-size: 0.9rem;">
                @error('price_per_night')
                    <span style="color: #EF4444; font-size: 0.8rem;">{{ $message }}</span>
                @enderror
            </div>
            
            <div>
                <label style="display: block; margin-bottom: var(--space-sm); font-weight: 600; color: var(--text-dark);">Bedrooms *</label>
                <input type="number" name="bedrooms" value="{{ old('bedrooms', $apartment->bedrooms) }}" required min="0"
                    style="width: 100%; padding: 12px; border: 1px solid var(--border-grey); border-radius: var(--radius-sm); font-size: 0.9rem;">
            </div>
            
            <div>
                <label style="display: block; margin-bottom: var(--space-sm); font-weight: 600; color: var(--text-dark);">Bathrooms *</label>
                <input type="number" name="bathrooms" value="{{ old('bathrooms', $apartment->bathrooms) }}" required min="0"
                    style="width: 100%; padding: 12px; border: 1px solid var(--border-grey); border-radius: var(--radius-sm); font-size: 0.9rem;">
            </div>
            
            <div>
                <label style="display: block; margin-bottom: var(--space-sm); font-weight: 600; color: var(--text-dark);">Area (m²) *</label>
                <input type="number" name="area" value="{{ old('area', $apartment->area) }}" required min="0" step="0.01"
                    style="width: 100%; padding: 12px; border: 1px solid var(--border-grey); border-radius: var(--radius-sm); font-size: 0.9rem;">
            </div>
            
            <div>
                <label style="display: block; margin-bottom: var(--space-sm); font-weight: 600; color: var(--text-dark);">Max Guests *</label>
                <input type="number" name="max_guests" value="{{ old('max_guests', $apartment->max_guests) }}" required min="1"
                    style="width: 100%; padding: 12px; border: 1px solid var(--border-grey); border-radius: var(--radius-sm); font-size: 0.9rem;">
            </div>
        </div>
        
        <div style="margin-top: var(--space-lg);">
            <label style="display: block; margin-bottom: var(--space-sm); font-weight: 600; color: var(--text-dark);">Description</label>
            <textarea name="description" rows="4"
                style="width: 100%; padding: 12px; border: 1px solid var(--border-grey); border-radius: var(--radius-sm); font-size: 0.9rem; resize: vertical;">{{ old('description', $apartment->description) }}</textarea>
        </div>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: var(--space-lg); margin-top: var(--space-lg);">
            <div>
                <label style="display: block; margin-bottom: var(--space-sm); font-weight: 600; color: var(--text-dark);">Address *</label>
                <input type="text" name="address" value="{{ old('address', $apartment->address) }}" required
                    style="width: 100%; padding: 12px; border: 1px solid var(--border-grey); border-radius: var(--radius-sm); font-size: 0.9rem;">
            </div>
            
            <div>
                <label style="display: block; margin-bottom: var(--space-sm); font-weight: 600; color: var(--text-dark);">City *</label>
                <input type="text" name="city" value="{{ old('city', $apartment->city) }}" required
                    style="width: 100%; padding: 12px; border: 1px solid var(--border-grey); border-radius: var(--radius-sm); font-size: 0.9rem;">
            </div>
            
            <div>
                <label style="display: block; margin-bottom: var(--space-sm); font-weight: 600; color: var(--text-dark);">Governorate *</label>
                <input type="text" name="governorate" value="{{ old('governorate', $apartment->governorate) }}" required
                    style="width: 100%; padding: 12px; border: 1px solid var(--border-grey); border-radius: var(--radius-sm); font-size: 0.9rem;">
            </div>
        </div>
        
        <div style="margin-top: var(--space-lg);">
            <label style="display: flex; align-items: center; gap: var(--space-sm); cursor: pointer;">
                <input type="checkbox" name="is_available" value="1" {{ old('is_available', $apartment->is_available) ? 'checked' : '' }}
                    style="width: 18px; height: 18px; cursor: pointer;">
                <span style="font-weight: 600; color: var(--text-dark);">Available for Booking</span>
            </label>
        </div>
        
        <div style="display: flex; gap: var(--space-md); margin-top: var(--space-2xl); padding-top: var(--space-lg); border-top: 1px solid var(--border-grey);">
            <button type="submit" style="background: var(--deep-green); color: white; border: none; padding: 12px 24px; border-radius: var(--radius-md); cursor: pointer; font-weight: 600; transition: var(--transition);">
                <i class="fas fa-save"></i> Save Changes
            </button>
            <a href="{{ route('admin.apartments.show', $apartment->id) }}" style="background: var(--light-grey); color: var(--text-dark); text-decoration: none; padding: 12px 24px; border-radius: var(--radius-md); font-weight: 600; transition: var(--transition); display: inline-block;">
                <i class="fas fa-times"></i> Cancel
            </a>
        </div>
    </form>
</div>
@endsection
