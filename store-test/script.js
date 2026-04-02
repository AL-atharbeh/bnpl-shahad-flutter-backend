const PRODUCTION_URL = 'https://enthusiastic-stillness-production-5dce.up.railway.app';
let origin = window.location.origin;

// If opening file locally or if origin is null, use production
if (origin === 'null' || !origin.startsWith('http')) {
    origin = PRODUCTION_URL;
}

const API_BASE_URL = origin + '/api/v1';

document.addEventListener('DOMContentLoaded', () => {
    const buyButtons = document.querySelectorAll('.buy-btn');
    const loader = document.getElementById('loader');

    buyButtons.forEach(button => {
        button.addEventListener('click', async (e) => {
            const productId = button.getAttribute('data-id');
            const productName = button.getAttribute('data-name');
            const productPrice = parseFloat(button.getAttribute('data-price'));

            await handleBuy(productId, productName, productPrice);
        });
    });

    async function handleBuy(id, name, price) {
        loader.classList.add('active');

        try {
            // 1. Create a session in the BNPL backend
            // For testing, we use store_id: 1 (should exist)
            const sessionData = {
                store_id: 1, 
                store_order_id: 'ORDER_' + Date.now(),
                total_amount: price,
                currency: 'JOD',
                installments_count: 4,
                items: [
                    {
                        name: name,
                        quantity: 1,
                        price: price,
                        product_id: 1 // Link to a test product
                    }
                ],
                success_url: window.location.href.split('?')[0] + '?success=true',
                cancel_url: window.location.href.split('?')[0] + '?cancel=true'
            };

            console.log('🚀 Creating session:', sessionData);

            const response = await fetch(`${API_BASE_URL}/sessions`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(sessionData)
            });

            const result = await response.json();

            if (result.success && result.session_id) {
                console.log('✅ Session created:', result.session_id);
                
                // For a real store integration, you might redirect to the web_redirect_url
                // which leads to the BNPL approval page.
                // Or if it's a integrated payment, the store shows options.
                
                // The user specifically asked to go to the "purchase page displaying traditional payment methods"
                // In our case, the backend generates a redirect_url for the app (bnpl://)
                // and a web_redirect_url for the browser.
                
                window.location.href = result.web_redirect_url;
            } else {
                throw new Error(result.message || 'فشل في إنشاء الجلسة');
            }

        } catch (error) {
            console.error('❌ Error:', error);
            alert('حدث خطأ أثناء معالجة الطلب: ' + error.message);
        } finally {
            loader.classList.remove('active');
        }
    }

    // Check for success/cancel params in URL
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('success')) {
        alert('✅ تم إكمال الطلب بنجاح! شكراً لك.');
        // Clean URL
        window.history.replaceState({}, document.title, window.location.pathname);
    } else if (urlParams.has('cancel')) {
        alert('⚠️ تم إلغاء عملية الدفع.');
        window.history.replaceState({}, document.title, window.location.pathname);
    }
});
