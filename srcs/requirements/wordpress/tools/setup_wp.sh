#!/bin/bash

# 1. Veritabanının uyanmasını bekle (MariaDB konteyneri)
# WordPress, veritabanı olmadan kurulamaz. MariaDB bizden biraz geç açılabilir.
# O yüzden "mysqladmin" ile sürekli dürtüp "Uyandın mı?" diye soruyoruz.
while ! mariadb -h$SQL_HOST -u$SQL_USER -p$SQL_PASSWORD $SQL_DATABASE &>/dev/null; do
    echo "MariaDB bekleniyor..."
    sleep 3
done

echo "MariaDB bağlantısı başarılı!"

# 2. WordPress daha önce kurulmuş mu kontrol et
# Eğer wp-config.php varsa, zaten kuruludur. Tekrar kurmaya çalışma.
if [ -f ./wp-config.php ]
then
    echo "WordPress zaten kurulu."
else
    echo "WordPress kurulumu başlıyor..."

    # 3. WordPress Çekirdek Dosyalarını İndir
    wp core download --allow-root

    # 4. Ayar Dosyasını (wp-config.php) Oluştur
    # Veritabanı bilgilerini .env dosyasından alıp buraya yazar.
    wp config create \
        --dbname=$SQL_DATABASE \
        --dbuser=$SQL_USER \
        --dbpass=$SQL_PASSWORD \
        --dbhost=$SQL_HOST \
        --allow-root

    # 5. WordPress'i Kur (Site Başlığı, Admin Kullanıcısı)
    # Bu adım veritabanına tabloları yazar.
    wp core install \
        --url=$DOMAIN_NAME \
        --title=$SITE_TITLE \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root

    # 6. İkinci Kullanıcıyı Oluştur (Proje Kuralı)
    # Admin dışında bir kullanıcı daha olmak zorunda.
    wp user create \
        $WP_USER \
        $WP_EMAIL \
        --role=author \
        --user_pass=$WP_PASSWORD \
        --allow-root

    echo "WordPress kurulumu tamamlandı!"
fi

# 7. PHP-FPM'i Başlat (Kritik Nokta)
# Scriptin görevi bitti ama konteynerin açık kalması lazım.
# PHP-FPM'i "foreground" (-F) modunda başlatıyoruz.
# NOT: Debian Bullseye için versiyon 7.4'tür.
exec /usr/sbin/php-fpm7.4 -F