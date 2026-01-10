<?php

namespace App\Models\Payment;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Support\Str;
use App\Models\User;

class OrangeMoneyTransaction extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'uuid',
        'user_id',
        'user_type',
        'order_id',
        'pay_token',
        'notif_token',
        'payment_url',
        'amount',
        'currency',
        'reference',
        'payment_for',
        'request_id',
        'plan_id',
        'status',
        'om_response',
        'om_transaction_id',
        'om_status',
        'om_error_message',
        'ip_address',
        'user_agent',
        'metadata',
        'initiated_at',
        'completed_at',
        'failed_at',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'metadata' => 'array',
        'initiated_at' => 'datetime',
        'completed_at' => 'datetime',
        'failed_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    protected $hidden = [
        'om_response',
    ];

    /**
     * Boot function
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            if (empty($model->uuid)) {
                $model->uuid = (string) Str::uuid();
            }
        });
    }

    /**
     * Relation avec l'utilisateur
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scopes
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeInitiated($query)
    {
        return $query->where('status', 'initiated');
    }

    public function scopeSuccess($query)
    {
        return $query->where('status', 'success');
    }

    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }

    public function scopeForWallet($query)
    {
        return $query->where('payment_for', 'wallet');
    }

    public function scopeForTrip($query)
    {
        return $query->where('payment_for', 'trip');
    }

    public function scopeForSubscription($query)
    {
        return $query->where('payment_for', 'subscription');
    }

    /**
     * Accesseurs
     */
    public function getFormattedAmountAttribute()
    {
        return number_format($this->amount, 0, ',', ' ') . ' ' . $this->currency;
    }

    public function getStatusLabelAttribute()
    {
        $labels = [
            'pending' => 'En attente',
            'initiated' => 'Initié',
            'processing' => 'En cours',
            'success' => 'Réussi',
            'failed' => 'Échoué',
            'cancelled' => 'Annulé',
            'refunded' => 'Remboursé',
        ];

        return $labels[$this->status] ?? $this->status;
    }

    public function getStatusColorAttribute()
    {
        $colors = [
            'pending' => 'warning',
            'initiated' => 'info',
            'processing' => 'primary',
            'success' => 'success',
            'failed' => 'danger',
            'cancelled' => 'secondary',
            'refunded' => 'dark',
        ];

        return $colors[$this->status] ?? 'secondary';
    }

    /**
     * Méthodes utilitaires
     */
    public function isPending()
    {
        return $this->status === 'pending';
    }

    public function isInitiated()
    {
        return $this->status === 'initiated';
    }

    public function isSuccess()
    {
        return $this->status === 'success';
    }

    public function isFailed()
    {
        return $this->status === 'failed';
    }

    public function isCancelled()
    {
        return $this->status === 'cancelled';
    }

    public function isCompleted()
    {
        return in_array($this->status, ['success', 'failed', 'cancelled', 'refunded']);
    }

    /**
     * Marquer comme initié
     */
    public function markAsInitiated($paymentData)
    {
        $this->update([
            'status' => 'initiated',
            'pay_token' => $paymentData['pay_token'] ?? null,
            'notif_token' => $paymentData['notif_token'] ?? null,
            'payment_url' => $paymentData['payment_url'] ?? null,
            'initiated_at' => now(),
        ]);
    }

    /**
     * Marquer comme réussi
     */
    public function markAsSuccess($omResponse = null)
    {
        $this->update([
            'status' => 'success',
            'om_response' => $omResponse ? json_encode($omResponse) : null,
            'om_status' => $omResponse['status'] ?? null,
            'om_transaction_id' => $omResponse['txnid'] ?? null,
            'completed_at' => now(),
        ]);
    }

    /**
     * Marquer comme échoué
     */
    public function markAsFailed($errorMessage = null, $omResponse = null)
    {
        $this->update([
            'status' => 'failed',
            'om_error_message' => $errorMessage,
            'om_response' => $omResponse ? json_encode($omResponse) : null,
            'failed_at' => now(),
        ]);
    }

    /**
     * Marquer comme annulé
     */
    public function markAsCancelled()
    {
        $this->update([
            'status' => 'cancelled',
            'failed_at' => now(),
        ]);
    }
}
