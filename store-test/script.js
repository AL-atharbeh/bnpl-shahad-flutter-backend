const PRODUCTION_URL = 'https://enthusiastic-stillness-production-5dce.up.railway.app';
let origin = window.location.origin;

if (origin === 'null' || !origin.startsWith('http')) {
    origin = PRODUCTION_URL;
}

const API_BASE_URL = origin + '/api/v1';

// Expose BNPL logic globally for checkout page
window.handleBnplBuy = async function(id, name, price) {
    const loader = document.getElementById('loader');
    if (loader) loader.classList.add('active');

    const storeId = parseInt(localStorage.getItem('merchant_store_id')) || 3;

    try {
        const sessionData = {
            store_id: storeId, 
            store_order_id: 'ORDER_' + Date.now(),
            total_amount: price,
            currency: 'JOD',
            installments_count: 4,
            items: [
                {
                    name: name,
                    quantity: 1,
                    price: price,
                    product_id: 1
                }
            ],
            success_url: window.location.href.split('?')[0].replace('checkout.html', 'index.html') + '?success=true',
            cancel_url: window.location.href.split('?')[0].replace('checkout.html', 'index.html') + '?cancel=true'
        };

        const apiKey = localStorage.getItem('merchant_api_key') || 'sh_pk_8daae693027044afb60725da';

        const response = await fetch(`${API_BASE_URL}/sessions/create`, {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'x-api-key': apiKey
            },
            body: JSON.stringify(sessionData)
        });

        const result = await response.json();

        if (result.success && result.session_id) {
            // Redirect to the BNPL web approval page
            window.location.href = result.web_redirect_url;
        } else {
            throw new Error(result.message || 'فشل في إنشاء الجلسة');
        }

    } catch (error) {
        console.error('❌ Error:', error);
        alert('حدث خطأ أثناء معالجة الطلب: ' + error.message);
    } finally {
        if (loader) loader.classList.remove('active');
    }
};

document.addEventListener('DOMContentLoaded', () => {
    const buyButtons = document.querySelectorAll('.buy-btn');

    buyButtons.forEach(button => {
        button.addEventListener('click', (e) => {
            const product = {
                id: button.getAttribute('data-id'),
                name: button.getAttribute('data-name'),
                price: parseFloat(button.getAttribute('data-price'))
            };

            // Store selected product and go to checkout
            localStorage.setItem('selectedProduct', JSON.stringify(product));
            window.location.href = 'checkout.html';
        });
    });

    // Check for success/cancel params
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('success')) {
        alert('✅ تم إكمال الطلب بنجاح عبر شهد BNPL! شكراً لك.');
        window.history.replaceState({}, document.title, window.location.pathname);
    } else if (urlParams.has('cancel')) {
        alert('⚠️ تم إلغاء عملية الدفع.');
        window.history.replaceState({}, document.title, window.location.pathname);
    }
});
