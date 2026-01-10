<?php

namespace App\Models\MoovMoney;

use App\Models\User;
use App\Base\Uuid\UuidModel;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class MoovMoneyTransaction extends Model
{
    use HasFactory, UuidModel, SoftDeletes;

    protected $fillable = [
        'user_id',
        'transaction_type',
        'status',
        'amount',
        'currency',
        'phone_number',
        'voucher_code',
        'voucher_validation_value',
        'voucher_expires_at',
        'agent_location',
        'agent_lat',
        'agent_lng',
        'agent_name',
        'agent_phone',
        'conversation_id',
        'transaction_id',
        'originator_conversation_id',
        'api_request',
        'api_response',
        'error_message',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'agent_lat' => 'decimal:7',
        'agent_lng' => 'decimal:7',
        'voucher_expires_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    /**
     * Relation avec l'utilisateur
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }

    /**
     * Scope pour les dépôts
     */
    public function scopeDeposits($query)
    {
        return $query->where('transaction_type', 'deposit');
    }

    /**
     * Scope pour les retraits
     */
    public function scopeWithdrawals($query)
    {
        return $query->where('transaction_type', 'withdrawal');
    }

    /**
     * Scope pour les transactions complétées
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    /**
     * Scope pour les transactions en attente
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Générer un code voucher unique
     */
    public static function generateVoucherCode()
    {
        do {
            $code = 'VC' . strtoupper(substr(md5(uniqid(mt_rand(), true)), 0, 10));
        } while (self::where('voucher_code', $code)->exists());

        return $code;
    }

    /**
     * Vérifier si le voucher est expiré
     */
    public function isVoucherExpired()
    {
        if (!$this->voucher_expires_at) {
            return false;
        }

        return now()->greaterThan($this->voucher_expires_at);
    }

    /**
     * Marquer la transaction comme complétée
     */
    public function markAsCompleted($transactionId = null, $conversationId = null)
    {
        $this->status = 'completed';
        if ($transactionId) {
            $this->transaction_id = $transactionId;
        }
        if ($conversationId) {
            $this->conversation_id = $conversationId;
        }
        $this->save();
    }

    /**
     * Marquer la transaction comme échouée
     */
    public function markAsFailed($errorMessage = null)
    {
        $this->status = 'failed';
        if ($errorMessage) {
            $this->error_message = $errorMessage;
        }
        $this->save();
    }
}
