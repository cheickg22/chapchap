<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Orange Money - Paiement</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #ff6b00, #ff8533);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .payment-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 450px;
            width: 100%;
            padding: 40px;
            animation: slideUp 0.5s ease-out;
        }
        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        .logo-container {
            text-align: center;
            margin-bottom: 30px;
        }
        .orange-logo {
            width: 180px;
            height: auto;
        }
        .amount-display {
            text-align: center;
            margin-bottom: 35px;
        }
        .amount-label {
            font-size: 14px;
            color: #666;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .amount-value {
            font-size: 42px;
            font-weight: bold;
            color: #ff6b00;
            line-height: 1;
        }
        .form-group {
            margin-bottom: 25px;
        }
        .form-group label {
            display: block;
            margin-bottom: 10px;
            font-weight: 600;
            color: #333;
            font-size: 14px;
        }
        .form-group input {
            width: 100%;
            padding: 15px;
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            font-size: 16px;
            transition: all 0.3s;
            font-family: inherit;
        }
        .form-group input:focus {
            outline: none;
            border-color: #ff6b00;
            box-shadow: 0 0 0 3px rgba(255, 107, 0, 0.1);
        }
        .form-group input::placeholder {
            color: #999;
        }
        .payment-button {
            background: linear-gradient(135deg, #ff6b00, #ff8533);
            color: white;
            padding: 18px;
            font-size: 18px;
            font-weight: 600;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            width: 100%;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 1px;
            box-shadow: 0 4px 15px rgba(255, 107, 0, 0.3);
        }
        .payment-button:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 107, 0, 0.4);
        }
        .payment-button:active:not(:disabled) {
            transform: translateY(0);
        }
        .payment-button:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
        .loading-container {
            display: none;
            text-align: center;
            margin-top: 25px;
        }
        .loading-container.active {
            display: block;
        }
        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #ff6b00;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin: 0 auto 15px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .loading-text {
            color: #666;
            font-size: 14px;
        }
        .message {
            padding: 15px;
            border-radius: 10px;
            margin-top: 20px;
            display: none;
            animation: fadeIn 0.3s;
        }
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        .message.active {
            display: block;
        }
        .error-message {
            background: #fee;
            border: 1px solid #fcc;
            color: #c33;
        }
        .success-message {
            background: #efe;
            border: 1px solid #cfc;
            color: #3c3;
        }
        .info-text {
            text-align: center;
            color: #666;
            font-size: 13px;
            margin-top: 25px;
            line-height: 1.6;
        }
        .secure-badge {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin-top: 20px;
            color: #999;
            font-size: 12px;
        }
        .secure-icon {
            width: 16px;
            height: 16px;
        }
    </style>
</head>
<body>
    <div class="payment-container">
        <div class="logo-container">
            <svg class="orange-logo" viewBox="0 0 200 60" xmlns="http://www.w3.org/2000/svg">
                <rect width="200" height="60" fill="#ff6b00" rx="8"/>
                <text x="100" y="38" font-family="Arial, sans-serif" font-size="24" font-weight="bold" fill="white" text-anchor="middle">Orange Money</text>
            </svg>
        </div>

        <div class="amount-display">
            <div class="amount-label">Montant à payer</div>
            <div class="amount-value">{{ number_format($amount, 0, ',', ' ') }} {{ $currency_code }}</div>
        </div>

        <form id="orangePaymentForm">
            <input type="hidden" name="amount" value="{{ $amount }}">
            <input type="hidden" name="currency" value="{{ $currency_code }}">
            <input type="hidden" name="user_id" value="{{ $user_id }}">
            <input type="hidden" name="payment_for" value="{{ $payment_for }}">
            <input type="hidden" name="request_id" value="{{ $request_id ?? '' }}">
            <input type="hidden" name="plan_id" value="{{ $plan_id ?? '' }}">

            <div class="form-group">
                <label for="mobile">
                    <svg style="width:16px;height:16px;display:inline;vertical-align:middle;margin-right:5px" viewBox="0 0 24 24">
                        <path fill="#ff6b00" d="M17,19H7V5H17M17,1H7C5.89,1 5,1.89 5,3V21A2,2 0 0,0 7,23H17A2,2 0 0,0 19,21V3C19,1.89 18.1,1 17,1Z" />
                    </svg>
                    Numéro Orange Money
                </label>
                <input 
                    type="tel" 
                    id="mobile" 
                    name="mobile" 
                    placeholder="Ex: 77 XX XX XX XX" 
                    required
                    pattern="[0-9]{8,10}"
                    maxlength="10"
                >
            </div>

            <button type="submit" class="payment-button" id="paymentButton">
                Payer maintenant
            </button>

            <div class="loading-container" id="loadingContainer">
                <div class="spinner"></div>
                <div class="loading-text">Traitement en cours...</div>
            </div>

            <div class="message error-message" id="errorMessage"></div>
            <div class="message success-message" id="successMessage"></div>
        </form>

        <div class="info-text">
            Vous recevrez une notification sur votre téléphone pour confirmer le paiement.
        </div>

        <div class="secure-badge">
            <svg class="secure-icon" viewBox="0 0 24 24">
                <path fill="#4CAF50" d="M12,1L3,5V11C3,16.55 6.84,21.74 12,23C17.16,21.74 21,16.55 21,11V5L12,1Z" />
            </svg>
            <span>Paiement sécurisé</span>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('orangePaymentForm');
            const button = document.getElementById('paymentButton');
            const loading = document.getElementById('loadingContainer');
            const errorMsg = document.getElementById('errorMessage');
            const successMsg = document.getElementById('successMessage');
            const mobileInput = document.getElementById('mobile');

            // Format phone number as user types
            mobileInput.addEventListener('input', function(e) {
                let value = e.target.value.replace(/\D/g, '');
                if (value.length > 10) value = value.slice(0, 10);
                e.target.value = value;
            });

            form.addEventListener('submit', async function(e) {
                e.preventDefault();
                
                const mobile = mobileInput.value.trim();
                
                // Validation
                if (!mobile || mobile.length < 8) {
                    showError('Veuillez entrer un numéro de téléphone valide (8 à 10 chiffres)');
                    return;
                }

                // Show loading
                button.disabled = true;
                loading.classList.add('active');
                hideMessages();

                const formData = new FormData(form);

                try {
                    const response = await fetch('{{ url("/payment/orange") }}', {
                        method: 'POST',
                        headers: {
                            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
                            'Accept': 'application/json',
                        },
                        body: formData
                    });

                    const data = await response.json();

                    loading.classList.remove('active');
                    button.disabled = false;

                    if (data.success && data.payment_url) {
                        showSuccess('Redirection vers la page de paiement...');
                        setTimeout(() => {
                            window.location.href = data.payment_url;
                        }, 1500);
                    } else {
                        showError(data.message || 'Erreur lors de l\'initiation du paiement');
                    }
                } catch (error) {
                    loading.classList.remove('active');
                    button.disabled = false;
                    showError('Erreur de connexion. Veuillez réessayer.');
                    console.error('Payment error:', error);
                }
            });

            function showError(message) {
                errorMsg.textContent = message;
                errorMsg.classList.add('active');
                successMsg.classList.remove('active');
            }

            function showSuccess(message) {
                successMsg.textContent = message;
                successMsg.classList.add('active');
                errorMsg.classList.remove('active');
            }

            function hideMessages() {
                errorMsg.classList.remove('active');
                successMsg.classList.remove('active');
            }
        });
    </script>
</body>
</html>
