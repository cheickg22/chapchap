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
            color: #88B04B;
            font-weight: 900;
            font-size: 40px;
            margin-bottom: 10px;
        }
        p {
            color: #404F5E;
            font-size: 20px;
            margin: 10px 0;
        }
        i.checkmark {
            color: #9ABC66;
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
            background: #f0f0f0;
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
        <div style="border-radius: 200px; height: 200px; width: 200px; background: #F8FAF5; margin: 0 auto;">
            <i class="checkmark">✓</i>
        </div>
        <h1>Paiement Réussi!</h1>
        <p>{{ $message ?? 'Votre paiement a été effectué avec succès!' }}</p>
        
        <div class="info">
            <p><strong>Montant:</strong> {{ number_format($amount, 0, ',', ' ') }} FCFA</p>
            <p><strong>Transaction ID:</strong> {{ $transaction_id }}</p>
        </div>

        <p class="countdown">Retour automatique dans <span id="countdown">3</span> secondes...</p>
    </div>

    <script>
        // Données de la transaction
        var paymentData = {
            success: true,
            amount: {{ $amount }},
            transaction_id: "{{ $transaction_id }}",
            payment_for: "{{ $payment_for ?? 'wallet' }}",
            request_id: "{{ $request_id ?? '' }}"
        };

        // Envoyer le message à Flutter WebView
        function notifyFlutter() {
            // Pour Flutter WebView
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('paymentSuccess', paymentData);
            }
            
            // Pour Android WebView
            if (window.Android && window.Android.paymentSuccess) {
                window.Android.paymentSuccess(JSON.stringify(paymentData));
            }
            
            // Pour iOS WebView
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.paymentSuccess) {
                window.webkit.messageHandlers.paymentSuccess.postMessage(paymentData);
            }

            // PostMessage pour communication avec parent window
            if (window.parent) {
                window.parent.postMessage({
                    type: 'PAYMENT_SUCCESS',
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
                
                // Fermer le WebView ou rediriger
                @if(isset($web_booking_value) && $web_booking_value == 1)
                    window.location.href = '{{ url("/") }}/history/view/{{ $request_id }}';
                @else
                    // Essayer de fermer le WebView
                    if (window.flutter_inappwebview) {
                        window.flutter_inappwebview.callHandler('closeWebView');
                    } else {
                        window.close();
                    }
                @endif
            }
        }, 1000);

        // Notifier immédiatement aussi
        notifyFlutter();
    </script>
</body>
</html>
