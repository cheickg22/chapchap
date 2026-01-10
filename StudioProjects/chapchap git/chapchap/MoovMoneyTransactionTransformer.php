<?php

namespace App\Transformers\MoovMoney;

use App\Models\MoovMoney\MoovMoneyTransaction;
use App\Transformers\Transformer;

class MoovMoneyTransactionTransformer extends Transformer
{
    /**
     * Transform the MoovMoneyTransaction model.
     *
     * @param MoovMoneyTransaction $transaction
     * @return array
     */
    public function transform(MoovMoneyTransaction $transaction)
    {
        return [
            'id' => $transaction->id,
            'transaction_type' => $transaction->transaction_type,
            'transaction_type_text' => $transaction->transaction_type === 'deposit' ? 'Dépôt' : 'Retrait',
            'status' => $transaction->status,
            'status_text' => $this->getStatusText($transaction->status),
            'amount' => (float) $transaction->amount,
            'currency' => $transaction->currency,
            'formatted_amount' => number_format($transaction->amount, 0, ',', ' ') . ' ' . $transaction->currency,
            'phone_number' => $transaction->phone_number,
            
            // Informations du voucher (pour retrait)
            'voucher_code' => $transaction->voucher_code,
            'voucher_validation_value' => $transaction->voucher_validation_value,
            'voucher_expires_at' => $transaction->voucher_expires_at ? $transaction->voucher_expires_at->toIso8601String() : null,
            'voucher_expired' => $transaction->isVoucherExpired(),
            
            // Informations de l'agent
            'agent_location' => $transaction->agent_location,
            'agent_lat' => $transaction->agent_lat ? (float) $transaction->agent_lat : null,
            'agent_lng' => $transaction->agent_lng ? (float) $transaction->agent_lng : null,
            'agent_name' => $transaction->agent_name,
            'agent_phone' => $transaction->agent_phone,
            
            // Informations de la transaction Moov Money
            'conversation_id' => $transaction->conversation_id,
            'transaction_id' => $transaction->transaction_id,
            
            // Métadonnées
            'error_message' => $transaction->error_message,
            'created_at' => $transaction->created_at->toIso8601String(),
            'updated_at' => $transaction->updated_at->toIso8601String(),
            'created_at_formatted' => $transaction->created_at->format('d/m/Y H:i'),
        ];
    }

    /**
     * Get status text in French
     *
     * @param string $status
     * @return string
     */
    private function getStatusText($status)
    {
        $statusTexts = [
            'pending' => 'En attente',
            'completed' => 'Complété',
            'failed' => 'Échoué',
            'cancelled' => 'Annulé',
        ];

        return $statusTexts[$status] ?? $status;
    }
}
