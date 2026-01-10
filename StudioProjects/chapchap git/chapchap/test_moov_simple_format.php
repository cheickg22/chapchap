<?php
/**
 * Test avec un format SOAP plus simple
 */

$shortcode = '22300001009';
$password = 'Accounting_2025test';
$cashOutUrl = 'https://api.moovmoney.ml:38443/apiaccess/IntegratingCashOut';
$conversationId = 'TEST_' . time();
$timestamp = date('YmdHis');
$phoneNumber = '22362335272';

// Format 1: Sans namespace api:Request
$soapEnvelope1 = <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope 
    xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" 
    xmlns:req="http://cps.huawei.com/cpsinterface/request" 
    xmlns:com="http://cps.huawei.com/cpsinterface/common">
  <soapenv:Header/>
  <soapenv:Body>
    <req:Request>
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
    </req:Request>
  </soapenv:Body>
</soapenv:Envelope>
XML;

// Format 2: Avec CommandID en majuscules
$soapEnvelope2 = <<<XML
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
        <req:COMMANDID>InitTrans_1101</req:COMMANDID>
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

// Format 3: CommandID directement dans Body
$soapEnvelope3 = <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Header/>
  <soapenv:Body>
    <Request xmlns="http://cps.huawei.com/cpsinterface/request">
      <CommandID>InitTrans_1101</CommandID>
      <Version>1.0</Version>
      <OriginatorConversationID>{$conversationId}</OriginatorConversationID>
      <Caller>
        <CallerType>2</CallerType>
        <ThirdPartyID>{$shortcode}</ThirdPartyID>
        <Password>{$password}</Password>
        <ResultURL>https://chapchap.ml/api/moov-money/callback</ResultURL>
      </Caller>
      <KeyOwner>1</KeyOwner>
      <Timestamp>{$timestamp}</Timestamp>
      <Identity>
        <Initiator>
          <IdentifierType>1</IdentifierType>
          <Identifier>{$phoneNumber}</Identifier>
        </Initiator>
      </Identity>
      <TransactionRequest>
        <Parameters>
          <Parameter>
            <Key>ReasonType</Key>
            <Value>Withdraw_Voucher</Value>
          </Parameter>
        </Parameters>
      </TransactionRequest>
    </Request>
  </soapenv:Body>
</soapenv:Envelope>
XML;

function testFormat($name, $envelope, $url) {
    echo "\n=== TEST: {$name} ===\n";
    echo substr($envelope, 0, 500) . "...\n\n";
    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $envelope);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: text/xml; charset=utf-8',
        'SOAPAction: ',
    ]);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    echo "HTTP: {$httpCode}\n";
    echo "Response: {$response}\n";
    
    if (strpos($response, '<') === 0) {
        echo "✅ XML Response (Success!)\n";
        return true;
    } else {
        $json = json_decode($response, true);
        echo "❌ JSON Error: " . ($json['message'] ?? 'Unknown') . "\n";
        return false;
    }
}

echo "=== Test de 3 formats SOAP différents ===\n";
echo "URL: {$cashOutUrl}\n";
echo "ConversationID: {$conversationId}\n\n";

testFormat("Format 1: req:Request (sans api:)", $soapEnvelope1, $cashOutUrl);
testFormat("Format 2: COMMANDID en majuscules", $soapEnvelope2, $cashOutUrl);
testFormat("Format 3: Format simplifié", $soapEnvelope3, $cashOutUrl);

echo "\n=== Fin des tests ===\n";
