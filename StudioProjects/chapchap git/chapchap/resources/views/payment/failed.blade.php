<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css?family=Nunito+Sans:400,400i,700,900&display=swap" rel="stylesheet">
    <style>
        body {
            text-align: center;
            padding: 40px 0;
            background: #EBF0F5;
            font-family: "Nunito Sans", "Helvetica Neue", sans-serif;
        }
        h1 {
            color: #D8000C;
            font-weight: 900;
            font-size: 40px;
            margin-bottom: 10px;
        }
        p {
            color: #404F5E;
            font-size: 20px;
            margin: 10px 0;
        }
        i.crossmark {
            color: #D8000C;
            font-size: 100px;
            line-height: 200px;
            margin-left: -15px;
        }
        .card {
            background: white;
            padding: 60px;
            border-radius: 4px;
            box-shadow: 0 2px 3px #C8D0D8;
            display: inline-block;
            margin: 0 auto;
        }
        .info {
            margin-top: 20px;
            padding: 15px;
            background: #ffebee;
            border-radius: 5px;
        }
        .countdown {
            color: #666;
            font-size: 14px;
            margin-top: 15px;
        }
    </style>
</head>
<body>
    <div class="card">
        <div style="border-radius: 200px; height: 200px; width: 200px; background: #FFEBEE; margin: 0 auto;">
            <i class="crossmark">✗</i>
        </div>
        <h1>Paiement Échoué</h1>
        <p>{{ $message ?? 'Votre paiement n\'a pas pu être traité.' }}</p>
        
        <div class="info">
            <p>Veuillez réessayer ou contacter le support si le problème persiste.</p>
        </div>

        <p class="countdown">Retour automatique dans <span id="countdown">3</span> secondes...</p>
    </div>

    <script>
        // Données de l'échec
        var paymentData = {
            success: false,
            message: "{{ $message ?? 'Payment failed' }}"
        };

        // Envoyer le message à Flutter WebView
        function notifyFlutter() {
            // Pour Flutter WebView
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('paymentFailed', paymentData);
            }
            
            // Pour Android WebView
            if (window.Android && window.Android.paymentFailed) {
                window.Android.paymentFailed(JSON.stringify(paymentData));
            }
            
            // Pour iOS WebView
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.paymentFailed) {
                window.webkit.messageHandlers.paymentFailed.postMessage(paymentData);
            }

            // PostMessage pour communication avec parent window
            if (window.parent) {
                window.parent.postMessage({
                    type: 'PAYMENT_FAILED',
                    data: paymentData
                }, '*');
            }
        }

        // Countdown et redirection
        var countdown = 3;
        var countdownElement = document.getElementById('countdown');
        
        var timer = setInterval(function() {
            countdown--;
            countdownElement.textContent = countdown;
            
            if (countdown <= 0) {
                clearInterval(timer);
                notifyFlutter();
                
                // Essayer de fermer le WebView
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('closeWebView');
                } else {
                    window.close();
                }
            }
        }, 1000);

        // Notifier immédiatement aussi
        notifyFlutter();
    </script>
</body>
</html>
