<?php
// Test de la relation moovMoneyTransaction

$request = App\Models\Request\Request::where('is_moov_money', 1)->first();

if (!$request) {
    echo "❌ Aucune requête Moov Money trouvée\n";
    exit;
}

echo "✅ Requête trouvée: " . $request->request_number . "\n";
echo "   is_moov_money: " . $request->is_moov_money . "\n";
echo "   moov_money_transaction_id: " . $request->moov_money_transaction_id . "\n";

try {
    $transaction = $request->moovMoneyTransaction;
    if ($transaction) {
        echo "✅ Relation fonctionne !\n";
        echo "   Transaction ID: " . $transaction->id . "\n";
        echo "   Voucher: " . $transaction->voucher_code . "\n";
    } else {
        echo "⚠️  Relation retourne null (transaction_id peut-être null)\n";
    }
} catch (\Exception $e) {
    echo "❌ Erreur relation: " . $e->getMessage() . "\n";
}
