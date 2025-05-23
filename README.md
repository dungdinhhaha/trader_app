# Trader App - Ứng dụng Quản lý Giao dịch Cá nhân

Ứng dụng quản lý giao dịch cá nhân giúp theo dõi và phân tích các giao dịch, phương pháp giao dịch, và tâm lý giao dịch của bạn.

## Tính năng chính

- 📊 **Quản lý Giao dịch**: Theo dõi các giao dịch, lợi nhuận/thua lỗ, và hiệu suất giao dịch
- 📈 **Phương pháp Giao dịch**: Lưu trữ và phân tích các phương pháp giao dịch của bạn
- 🧠 **Kiểm tra Tâm lý**: Đánh giá và cải thiện tâm lý giao dịch
- 🤖 **Phân tích AI**: Sử dụng ChatGPT để phân tích phương pháp giao dịch và đưa ra khuyến nghị

## Cài đặt

1. Clone repository:
```bash
git clone https://github.com/dungdinhhaha/trader_app.git
cd trader_app
```

2. Cài đặt dependencies:
```bash
flutter pub get
```

3. Tạo file `.env` trong thư mục gốc với các biến môi trường sau:
```
# OpenAI API Key
OPENAI_API_KEY=your_openai_api_key_here

# Supabase Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

4. Chạy ứng dụng:
```bash
flutter run
```

## Cấu trúc dự án

```
lib/
├── app/                    # Cấu hình ứng dụng
├── config/                 # Cấu hình (API keys, etc.)
├── core/                   # Core functionality
│   ├── api/               # API clients
│   ├── models/            # Data models
│   └── services/          # Business logic services
└── features/              # UI features
    ├── auth/              # Authentication
    ├── dashboard/         # Dashboard
    ├── methods/           # Trading methods
    ├── orders/            # Trade orders
    └── psychology/        # Psychology tests
```

## Sử dụng

### Quản lý Giao dịch
- Thêm giao dịch mới với thông tin chi tiết
- Theo dõi trạng thái và kết quả giao dịch
- Phân tích hiệu suất giao dịch

### Phương pháp Giao dịch
- Tạo và lưu trữ các phương pháp giao dịch
- Phân tích phương pháp với AI
- Theo dõi hiệu suất của từng phương pháp

### Kiểm tra Tâm lý
- Thực hiện bài kiểm tra tâm lý giao dịch
- Nhận phân tích và khuyến nghị từ AI
- Theo dõi sự tiến bộ của bạn

## Đóng góp

Mọi đóng góp đều được hoan nghênh! Vui lòng tạo issue hoặc pull request để đóng góp.

## Giấy phép

MIT License - Xem file [LICENSE](LICENSE) để biết thêm chi tiết.
#
