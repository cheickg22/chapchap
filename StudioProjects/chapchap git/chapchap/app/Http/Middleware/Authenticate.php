<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use App\Models\Setting;
use Illuminate\Http\Request;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     */
    protected function redirectTo(Request $request): ?string
    {
        // Pour les requêtes API, ne pas rediriger mais laisser retourner 401
        if ($request->expectsJson() || 
            $request->is('api/*') || 
            $request->header('Accept') === 'application/json' ||
            $request->header('X-Requested-With') === 'XMLHttpRequest') {
            return null;
        }
        
        $admin_url = Setting::where('name','admin_login')->pluck('value')->first();
        $admin_url = "login/".$admin_url;

        return redirect()->guest($admin_url);
    }
}
