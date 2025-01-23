const plateInput = document.getElementById('plateInput');
const saveButton = document.getElementById('saveButton');
const cancelButton = document.getElementById('cancelButton');

// Hata mesajları için sabit tanımla
const ERROR_MESSAGES = {
    INVALID_PLATE: 'Plaka 3-7 karakter arasında olmalı ve sadece harf ve rakam içermelidir!'
};

// Kaydet butonunun başlangıç durumu
saveButton.disabled = true;

// Plaka formatı kontrolü
function isValidPlate(plate) {
    const plateRegex = /^[A-Za-z0-9]{3,7}$/;
    return plateRegex.test(plate);
}

// Input kontrolü
plateInput.addEventListener('input', (e) => {
    e.target.value = e.target.value.toUpperCase();
    // Sadece harf ve rakam girişine izin ver
    e.target.value = e.target.value.replace(/[^A-Z0-9]/g, '');
    
    // Plaka geçerliliğine göre buton durumunu güncelle
    const isValid = isValidPlate(e.target.value);
    saveButton.disabled = !isValid;
    
    // Görsel geri bildirim için class ekle/çıkar
    if (isValid) {
        plateInput.classList.remove('invalid');
        plateInput.classList.add('valid');
    } else {
        plateInput.classList.remove('valid');
        plateInput.classList.add('invalid');
    }
});

// Kaydet butonu
saveButton.addEventListener('click', () => {
    const plate = plateInput.value;
    
    if (!isValidPlate(plate)) {
        // QB-Core notify
        sendNUIMessage('errorMessage', { message: ERROR_MESSAGES.INVALID_PLATE });
        return;
    }

    // Plakayı QB-Core'a gönder
    sendNUIMessage('savePlate', { plate: plate });

    // Arayüzü kapat
    closeUI();
});

// İptal butonu
cancelButton.addEventListener('click', () => {
    closeUI();
});

// Arayüzü kapatma fonksiyonu
function closeUI() {
    sendNUIMessage('closeUI');
}

// ESC tuşu ile kapatma
document.addEventListener('keyup', (e) => {
    if (e.key === 'Escape') {
        closeUI();
    }
});

// NUI mesajlarını dinle
window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type === 'openUI') {
        document.body.style.display = 'flex';
        plateInput.value = data.currentPlate || '';
        plateInput.focus();
    }
});

// Başlangıçta arayüzü gizle
document.body.style.display = 'none';

// Fetch işlemlerini tek fonksiyonda topla
const sendNUIMessage = async (endpoint, data = {}) => {
    try {
        await fetch(`https://${GetParentResourceName()}/${endpoint}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });
    } catch (error) {
        console.error('NUI Error:', error);
    }
};