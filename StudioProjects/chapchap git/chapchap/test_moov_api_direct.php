<?php
/**
 * Test direct de l'API Moov Money
 * Pour identifier le problème exact
 */

// Credentials
$shortcode = '22300001009';
$username = '00001009';
$password = 'Accounting_2025test';
$cashOutUrl = 'https://api.moovmoney.ml:38443/apiaccess/IntegratingCashOut';

// Générer les données
$conversationId = 'TEST_' . time();
$timestamp = date('YmdHis');
$phoneNumber = '22362335272';

// Construire la requête SOAP
$soapEnvelope = <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope 
    xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" 
    xmlns:api="http://cps.huawei.com/cpsinterface/api_requestmgr" 
    xmlns:req="http://cps.huawei.com/cpsinterface/request" 
    xmlns:com="http://cps.huawei.com/cpsinterface/common">
  <soapenv:Header/>
  <soapenv:Body>
    <api:Request>
      <req:Header>
        <req:Version>1.0</req:Version>
        <req:CommandID>InitTrans_1101</req:CommandID>
        <req:OriginatorConversationID>{$conversationId}</req:OriginatorConversationID>
        <req:Caller>
          <req:CallerType>2</req:CallerType>
          <req:ThirdPartyID>{$shortcode}</req:ThirdPartyID>
          <req:Password>{$password}</req:Password>
          <req:ResultURL>https://chapchap.ml/api/moov-money/callback</req:ResultURL>
        </req:Caller>
        <req:KeyOwner>1</req:KeyOwner>
        <req:Timestamp>{$timestamp}</req:Timestamp>
      </req:Header>
      <req:Body>
        <req:Identity>
          <req:Initiator>
            <req:IdentifierType>1</req:IdentifierType>
            <req:Identifier>{$phoneNumber}</req:Identifier>
          </req:Initiator>
        </req:Identity>
        <req:TransactionRequest>
          <req:Parameters>
            <req:Parameter>
              <com:Key>ReasonType</com:Key>
              <com:Value>Withdraw_Voucher</com:Value>
            </req:Parameter>
          </req:Parameters>
        </req:TransactionRequest>
      </req:Body>
    </api:Request>
  </soapenv:Body>
</soapenv:Envelope>
XML;

echo "=== Test API Moov Money ===\n\n";
echo "URL: {$cashOutUrl}\n";
echo "Shortcode: {$shortcode}\n";
echo "Username: {$username}\n";
echo "ConversationID: {$conversationId}\n\n";

echo "=== Requête SOAP ===\n";
echo $soapEnvelope . "\n\n";

// Envoyer la requête
$ch = curl_init($cashOutUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $soapEnvelope);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: text/xml; charset=utf-8',
    'SOAPAction: ',
]);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);
curl_setopt($ch, CURLOPT_VERBOSE, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "=== Réponse ===\n";
echo "HTTP Code: {$httpCode}\n";
if ($error) {
    echo "Erreur cURL: {$error}\n";
}
echo "Body:\n{$response}\n\n";

// Analyser la réponse
if (strpos($response, '{') === 0) {
    echo "=== Réponse JSON (Erreur) ===\n";
    $json = json_decode($response, true);
    print_r($json);
} else if (strpos($response, '<') === 0) {
    echo "=== Réponse XML (Succès) ===\n";
    echo $response;
} else {
    echo "=== Format Inconnu ===\n";
    echo $response;
}
