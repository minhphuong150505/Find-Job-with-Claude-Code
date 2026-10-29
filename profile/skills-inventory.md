# Skills Inventory — Nguyễn Minh Phương

> Lập ngày 2026-10-28 từ GitHub `minhphuong150505` (18 repo public, đọc qua git: file tree, file dependency, README, lịch sử commit) và 7 CV master trên Overleaf.
> Đây là **nguồn sự thật** cho skill `overleaf-cv-tailor` (quy tắc CV số 4: không bịa).

**Ký hiệu bằng chứng**
- ✅ **Code**: có trong code/dependency/commit trong repo public (ghi rõ file).
- 🟡 **Một phần**: repo có nhưng yếu (chỉ README, scaffold, hoặc phạm vi nhỏ hơn claim).
- 📄 **Chỉ CV**: không kiểm chứng được từ GitHub (việc ở công ty, số người dùng, kết quả lưu private…). Chỉ dùng khi người dùng đã xác nhận (xem mục "Đã xác nhận").

**Mức thành thạo ước lượng** (dựa trên số repo + độ sâu + test): ★★★ dùng thường xuyên, có test/production · ★★ dùng thật trong ≥1 project · ★ thử/scaffold.

---

## 1. Project → techstack có bằng chứng

### 1.1 META-CXR — VLM sinh báo cáo X-quang ngực  ·  [`Meta-CXR`](https://github.com/minhphuong150505/Meta-CXR)
- **Vai trò**: tác giả chính. 295/322 commit (2025-01-26 → 2026-09-09); 22 commit đầu là của tác giả gốc (Dasith Edirisinghe) → đây là **bản mở rộng** của META-CXR (IEEE Access 2025), không phải code viết từ đầu.
- **Stack** ✅ `requirements-stage1.txt`, `requirements-stage2.txt`, `pyproject.toml`, `Dockerfile`:
  Python ≥3.10 · PyTorch 2.5.1 · torchvision · Transformers 4.53 · PEFT 0.15 · bitsandbytes (QLoRA) · accelerate · timm · einops · fairscale · scikit-learn · scikit-image · OpenCV · pandas · pyarrow · W&B · spaCy · NLTK · pycocoevalcap · bert-score · OmegaConf · pytest · ruff · Docker.
- **Kiến trúc** ✅ (thư mục `vision_encoders/`, `biovil_t/`, `mhcac/`, `stage2/`, `medgemma_inference/`, `safety/`): 2 vision encoder y tế (BioViL-T, PubMedCLIP) + Q-Former + MHCAC, multi-view theo study, phân loại 14 nhãn CheXpert; Stage 2 MedGemma QLoRA sinh FINDINGS; lớp `safety/`.
- **Số liệu đo được** ✅ (README.md):
  - Stage 1 cuối (`run_20260820_ft`, epoch 9), test **3.269 study** MIMIC-CXR: macro-AUROC **0.7643** [0.7545, 0.7740], positive macro-F1 0.3542, macro-AUPRC 0.3203.
  - So với bản trước (paired bootstrap cùng 3.269 study): ΔAUROC **+0.0201** [+0.0136, +0.0263] → tương đương **0.744 → 0.764**.
  - Train full 10/10 epoch trên **1× RTX 5060 Ti 16 GB** (~12–15 h/run); hết kernel fault sau khi tắt XMP (+1.3% tốc độ).
  - Phát hiện **166 bbox MS-CXR** lệch split (rò vào test).
  - Bug stop token: **78%** token sinh ra là filler (commit 2026-09-09).
  - A/B explanation loss 5 epoch: không có tác dụng đo được → đã tắt (2026-08-17).
  - Test: **1.012 passed** (docs, lần chạy gần nhất); 935 hàm `test_` trong `tests/`. (Các số cũ hơn: 565 passed.)
  - Train set ~222.758 study.
- 📄 **Chưa tìm thấy trong repo**: CIDEr 0.007 → 0.168 (25 ca), cue precision 18% → 68%, patch cosine 0.674 → −0.014. Có thể nằm trong kết quả private → cần người dùng xác nhận.

### 1.2 META-CXR-SMOKETEST & Meta-CXR-GCP — hạ tầng train
- `META-CXR-SMOKETEST` (108 commit, solo) ✅: train Stage 1 trên **Kaggle 2× T4 bằng DDP** (`tests/test_ddp_itm_collective.py`, `test_distributed_eval_sampler.py`), checkpoint lên **Google Cloud Storage**, W&B, notebook tham số hoá; đánh giá encoder-sensitivity (Table 5).
- `Meta-CXR-GCP` (2 commit, solo) 🟡: scaffold chuyển notebook sang **GCP Compute Engine 2× T4 spot**: Dockerfile, Artifact Registry, gcsfuse, papermill, ADC, shell script 01..08, ước tính chi phí. README Meta-CXR ghi các recipe GCP **đã gỡ 2026-08-13** → chỉ là thử nghiệm. ⚠ Profile README ghi "Vertex AI" nhưng code dùng **Compute Engine**, không phải Vertex AI.

### 1.3 FPT Tri Thức — Enterprise RAG Assistant  ·  [`milvus-rag-demo`](https://github.com/minhphuong150505/milvus-rag-demo)
- **Vai trò**: solo (5 commit, 2026-05-03 → 2026-09-14).
- **Stack** ✅ `backend/pom.xml`, `ingestion/requirements.txt`, `frontend/package.json`, `docker-compose.yml`:
  Java 17 · Spring Boot 3.3 · milvus-sdk-java · Python (pymilvus 2.4, trafilatura, pypdf, BeautifulSoup, **langchain-text-splitters**, pydantic-settings) · Milvus 2.4 + Attu + MinIO · Ollama (embedding + chat, hoặc Ollama Cloud) · React 18 + Vite · react-markdown · Playwright + axe-core · Docker Compose · Nginx (`frontend/nginx.conf`).
- **Tính năng** ✅ README: ingestion PDF/web/text → chunk → embed → Milvus; dedup bằng hash (`ingestion/src/pipeline.py`); lấy 64 candidate → re-rank cosine + keyword/bigram coverage → Top K; streaming SSE + fallback JSON; trích dẫn nguồn; 12 tin nhắn lịch sử / tối đa 6.000 ký tự.
- **Test** ✅: **25** test JUnit/Mockito (5 file: controller, reranker, stream parser, prompt builder, orchestrator); **12** test frontend (`e2e/chat.spec.js` 9, `tests/stream.test.js` 3). ⚠ CV SE ghi "14 Playwright E2E tests" → repo chỉ có 9 E2E (+3 unit).
- Dữ liệu: ~40 file tài liệu FPT (báo cáo thường niên 2024, ESG…) trong `ingestion/data/processed/`.
- ⚠ "LangChain" trong CV = chỉ `langchain-text-splitters`, không dùng chain/agent của LangChain.

### 1.4 Chinese Learning Platform — AI web app  ·  [`Web_Chinese_Learning-`](https://github.com/minhphuong150505/Web_Chinese_Learning-)
- **Vai trò**: solo (25 commit, 2026-06-01 → 2026-07-01 trên GitHub).
- **Stack** ✅ `backend/pom.xml`, `tts-service/requirements.txt`, `frontend/package.json`, `deploy/`:
  Java 21 · Spring Boot **3.3.5** · Spring Security · JJWT · Google API client (Google sign-in) · WebFlux/WebClient · Azure Speech SDK · PostgreSQL · **Flyway (9 migration)** · Testcontainers/JUnit · Python **FastAPI** + edge-tts + praat-parselmouth (phân tích F0 / thanh điệu) · React + TypeScript + TanStack Query + Tailwind + pinyin-pro + react-pdf · Docker · **Caddy** (`deploy/Caddyfile`) · GCP (`deploy/gcp-startup.sh`, `docker-compose.gcp.yml`).
- **Tính năng** ✅: Chat với LLM tutor (OpenAI-compatible) + TTS + voice; chấm phát âm theo từ/âm tiết; dịch Việt↔Trung; chữa bài viết; học HSK 1–4; đa người dùng, dữ liệu theo `userId`; thêm luyện tiếng Anh (2026-06-30).
- **Test** ✅: **90** test case / 20 file (controller WebMvc, repository, LLM client, tone analysis…). 8 controller.
- 📄 "used by dozens of real users", "built in under 2 months", "deployed on GCP over HTTPS": có file deploy GCP + Caddy, nhưng **số người dùng** không kiểm chứng được.

### 1.5 Lensora — Chợ thiết bị máy ảnh (Android + Backend)  ·  [`Lensora`](https://github.com/minhphuong150505/Lensora) (fork của repo nhóm)
- **Vai trò** ✅ git: 2 người commit, minhphuong150505 **48/78** commit (backend 33 vs 25, frontend Android 28 vs 16) → khớp "lead developer (1 of 2 developers)". 📄 "Team of 4": git chỉ thấy 2 người code.
- **Stack** ✅ `backend/pom.xml`, `frontend/app/build.gradle.kts`: Java 21 · Spring Boot 3.4.2 · Spring Security + JWT + OAuth2 client · Spring Mail · PostgreSQL · **Flyway (11 migration)** · H2 · Docker Compose · Android (Java/XML, minSdk 24, compileSdk 36) · Retrofit.
- **Tích hợp** ✅: MoMo (`MoMoService.java`, `MomoQrPaymentActivity`), GHN (`ShippingController`), chatbot DeepSeek (`ChatbotController`).
- **Quy mô** ✅: **16 controller**, 41 entity/model. ⚠ CV ghi "all 11 API modules" → repo có 16 controller (gồm Health, Asset… nên "11 module nghiệp vụ" có thể đúng tuỳ cách đếm).
- Test tự động: hầu như không có (2 test mẫu) → CV ghi đúng là "manual + Postman testing".

### 1.6 Camera Shop (Mobile-App_Backend + Mobile-App-Frontend), bản trước Lensora
- Backend ✅ solo, 7 commit (2026-04): Java 17 · Spring Boot 3.2.4 · Spring Security/JWT · OAuth2 · JPA · MySQL · Mail · Docker Compose · 12 controller, 18 entity · MoMo · chatbot AI proxy. Không có test tự động.
- Frontend ✅ solo, 5 commit: React Native + **Expo** + Expo Router + NativeWind + TypeScript.

### 1.7 Personal Productivity Hub  ·  [`Personal_app_takenote`](https://github.com/minhphuong150505/Personal_app_takenote)
- **Vai trò**: solo (46 commit, 2026-05-19 → 05-21).
- **Stack** ✅ `api/pom.xml`, `web/package.json`: Java 21 · Spring Boot · JDBC · **Redis** (spring-data-redis, `RedisConfig.java`) + Spring Cache · Reactor (SSE) · PostgreSQL · Flyway (7) · **Testcontainers** · **WireMock** · React 19 + TypeScript + Vite + Tailwind v4 + Radix UI + Zustand + TanStack Query + BlockNote + dnd-kit · **Vitest** + Testing Library + axe-core · ESLint/Prettier/Husky/lint-staged.
- **Tính năng** ✅: chat AI nhiều nhà cung cấp (Anthropic, OpenAI, Gemini, Qwen, DeepSeek, Ollama) qua provider registry + SSE streaming; note kiểu Notion với ETag/optimistic concurrency; dịch EN→VI; nhạc YouTube.
- **Test** ✅: **126** test case / 31 file. Đây là repo có **chất lượng test cao nhất** nhưng **chưa có trong CV nào**.

### 1.8 Taskly Todo App  ·  [`Todo-App`](https://github.com/minhphuong150505/Todo-App)
- Solo, 11 commit (2026-07-06 → 07). ✅ Java 21 · Spring Boot 3.5 · Spring Security + JJWT (**access token trong cookie HttpOnly + refresh token hash & rotate phía server**) · JPA · H2/PostgreSQL 16 theo profile · springdoc-openapi (Swagger) · React 19 + Vite + Axios · Docker multi-stage + Nginx · **34** test (unit + integration auth flow). Kiến trúc layered, DTO/mapper, GlobalExceptionHandler.

### 1.9 Phuong Library — Library Management System  ·  [`Library-Management-System-Backend`](https://github.com/minhphuong150505/Library-Management-System-Backend)
- 16 commit (tác giả chính, gồm 2 email khác của chính bạn). ✅ Java 17 · Spring Boot 3.5.6 · Spring Security + JWT + **Google OAuth2** · JPA · MySQL 8.4 · Spring Mail · **Stripe + Razorpay** (`service/gateway/`) · React 19 + Redux Toolkit + MUI + Tailwind · Docker Compose + Nginx. 16 controller, 15 entity. Không có test tự động.

### 1.10 BABÉ 26 Landing page  ·  [`landing-page`](https://github.com/minhphuong150505/landing-page)
- Solo, 11 commit (2026-04-29 → 05-01). ✅ Java 17 · Spring Boot · JPA · Actuator · MySQL · React + TS + Tailwind + react-hook-form + Leaflet · **Resend email** · JWT admin · **GitHub Actions** (`.github/workflows/google.yml`) · Docker Compose prod · **deploy GCP production** với domain thật (README). Dự án làm cho khách hàng thật (sự kiện chạy bộ 10.05.2026), cần người dùng xác nhận có phải freelance không.

### 1.11 LifeSim — game web mô phỏng sơ cứu  ·  [`LifeSim---GameInWeb`](https://github.com/minhphuong150505/LifeSim---GameInWeb)
- Solo, 3 commit (2026-10-14 → 10-26). ✅ Vite · React · TypeScript strict · Tailwind · Zustand persist · Framer Motion · React-Leaflet/OSM · Howler.js · PWA · **Vitest (42 test)** · Vercel.

### 1.12 Dự án môn học / khác
- `WEB_PROJECT_2025_2026_UIT` (SE104, 3 commit) 🟡: Node.js + Express + Sequelize + MySQL + JWT + Multer + import XLSX; React + TS + Radix/shadcn. Có commit cả `node_modules` (13.858 file).
- `JAVA_PROJECT_FINAL` (2025-06, 3 commit) 🟡: ứng dụng Java desktop (Swing `.form`, JasperReports `.jrxml`) + SQL.
- `portfolio` (Next.js 15 + Tailwind + Framer Motion), `Chi-Porfolio` (Next.js 16 portfolio cho người khác, Vercel) ✅ nhỏ.

---

## 2. Ma trận kỹ năng (tổng hợp)

| Nhóm | Kỹ năng | Bằng chứng | Mức |
|---|---|---|---|
| Ngôn ngữ | Java 17/21 | 8 repo | ★★★ |
| | Python | Meta-CXR, RAG ingestion, FastAPI TTS | ★★★ |
| | TypeScript / JavaScript | 9 repo frontend | ★★ |
| | SQL | Flyway migration (Lensora 11, Chinese 9, Hub 7) | ★★ |
| Backend | Spring Boot 3 (Web, Security, Data JPA, Validation, Mail, OAuth2 client) | 8 repo | ★★★ |
| | JWT (JJWT), Google OAuth2, refresh-token rotation, HttpOnly cookie | Todo, Library, Lensora, Chinese | ★★★ |
| | WebClient/WebFlux, Reactor SSE streaming | Chinese, Hub, RAG | ★★ |
| | REST API + springdoc/Swagger | Todo | ★★ |
| | FastAPI | tts-service | ★★ |
| | Node.js + Express + Sequelize | WEB_PROJECT (môn học) | ★ |
| Database | PostgreSQL, MySQL, Flyway, H2 | nhiều repo | ★★★ |
| | Redis + Spring Cache | Hub | ★ |
| | Milvus 2.4 (vector DB) | RAG | ★★ |
| AI/ML | PyTorch, Transformers, PEFT/QLoRA, bitsandbytes | Meta-CXR | ★★★ |
| | Vision-Language Models (Q-Former/BLIP-2, MedGemma), multi-encoder fusion | Meta-CXR | ★★ |
| | Distributed training DDP (2× T4) | SMOKETEST | ★★ |
| | Evaluation: AUROC/AUPRC/F1, calibration, bootstrap CI, ablation, BLEU/ROUGE/BERTScore | Meta-CXR | ★★★ |
| | Grad-CAM / XAI | Meta-CXR | ★★ |
| | RAG, embeddings, re-ranking, Ollama | RAG | ★★ |
| | Tích hợp LLM API nhiều provider (OpenAI-compatible, Anthropic, Gemini, DeepSeek) | Hub, Chinese, Lensora | ★★ |
| | W&B, spaCy, scikit-learn, pandas, NumPy | Meta-CXR | ★★ |
| Frontend | React 18/19, Vite, Tailwind, TanStack Query, Zustand, Redux Toolkit, MUI, Radix | nhiều repo | ★★ |
| | Next.js | 2 portfolio | ★ |
| Mobile | Android Java/XML + Retrofit | Lensora | ★★ |
| | React Native + Expo | Mobile-App-Frontend | ★ |
| Testing | JUnit 5, Mockito, Spring WebMvcTest, Testcontainers, WireMock | Hub, Chinese, RAG, Todo | ★★★ |
| | pytest | Meta-CXR (1.012 passed) | ★★★ |
| | Vitest, Testing Library, Playwright, axe-core | Hub, LifeSim, RAG | ★★ |
| DevOps | Docker, Docker Compose, multi-stage build | ~10 repo | ★★★ |
| | Nginx, Caddy | Todo/Library/RAG, Chinese | ★★ |
| | GCP (Compute Engine, GCS, Artifact Registry), deploy production | landing-page, Chinese, GCP repo | ★★ |
| | GitHub Actions | landing-page (1 workflow) | ★ |
| | Linux, CUDA, vận hành máy train GPU | Meta-CXR | ★★ |
| Tích hợp | MoMo, GHN, DeepSeek, Azure Speech, Resend, Stripe, Razorpay | Lensora, Chinese, landing, Library | ★★ |
| Quy trình | Làm việc với AI agent (CLAUDE.md trong 5 repo), commit message chi tiết | Meta-CXR, RAG, Hub… | ★★ |

---

## 3. Đối chiếu với CV master

### 3.1 Có trong code nhưng **chưa có trong CV nào**
- **Personal Productivity Hub**: 126 test, Testcontainers, WireMock, Redis, SSE đa provider LLM (Anthropic/OpenAI/Gemini/Qwen/DeepSeek/Ollama).
- **Taskly Todo**: refresh-token rotation + HttpOnly cookie, springdoc/Swagger, 34 test.
- **Phuong Library**: Stripe + Razorpay, Redux Toolkit, MUI.
- **BABÉ landing page**: deploy production trên GCP, domain thật, GitHub Actions (nếu là việc freelance thì có thể ghi thành kinh nghiệm).
- **DDP multi-GPU (2× T4 Kaggle)**, Google Cloud Storage, W&B, papermill.
- **React Native / Expo**, **Next.js**, **Vitest**, **Zustand**, **TanStack Query**, **Testcontainers**, **Redis**.
- **LifeSim** (dự án mới nhất, 2026-10): React + TS strict + PWA + 42 test.

### 3.2 Claim trong CV **chưa có bằng chứng** hoặc **không khớp** giữa các CV
| # | Claim | Ở CV nào | Thực tế |
|---|---|---|---|
| 1 | Thời gian thực tập FPT Software | SE-AI/SE/LLM/Fullstack: **Mar–Sep 2026** · Java: **Aug–Oct 2026** · Backend: **May–Sep 2026** | 📄 3 mốc khác nhau → cần mốc đúng |
| 2 | Tên dự án FPT | **BUHINHYO** (đa số) vs **BUHINH** (Backend) | 📄 cần tên đúng |
| 3 | Số test META-CXR | **565** (SE-AI) · **541** (Backend) · **1,012** (LLM) | ✅ docs mới nhất: **1.012 passed** |
| 4 | META-CXR là gì | "Graduation thesis" (LLM) vs "Self-directed research" (SE-AI, Backend) | 📄 cần xác nhận |
| 5 | CIDEr 0.007 → 0.168 (25 ca); cue precision 18% → 68%; patch cosine 0.674 → −0.014 | LLM, DS | 📄 không tìm thấy trong repo public |
| 6 | Chinese app "used by dozens of real users" | SE-AI, SE, Java, Fullstack, LLM, Backend | 📄 không kiểm chứng được |
| 7 | Lensora "Team of 4" | SE, Java, Fullstack, Backend | 🟡 git chỉ có 2 người code |
| 8 | RAG "14 Playwright E2E tests" | SE | ⚠ repo: 9 E2E + 3 unit = 12 |
| 9 | **VNPay** trong Integrations | SE-AI, SE, Java, Fullstack | ❌ không thấy trong repo nào (MoMo thì có) |
| 10 | GitLab, Jira, Confluence, Java EE, JSP, Servlet, GitHub Copilot | nhiều CV | 📄 từ công việc FPT, không có trên GitHub (bình thường) |
| 11 | Big Data, Distributed Database, OSI Model | SE-AI, SE | 📄 môn học |
| 12 | LangChain | SE, LLM | 🟡 chỉ dùng `langchain-text-splitters` |
| 13 | Multi-Agent Orchestration, Context Engineering, Agentic Workflows | SE, Java, Fullstack | 🟡 chỉ có CLAUDE.md trong repo |
| 14 | Tốt nghiệp **Jun 2027** vs **May 2027** (DS) | | 📄 cần mốc đúng |
| 15 | English **B2** vs **Intermediate** (DS) | | 📄 có chứng chỉ không? |
| 16 | R, Power BI | DS, profile README | 📄 không có repo |

---

## 4. Đã xác nhận bởi người dùng (2026-10-28)

Khi chỉnh CV, **mục này được ưu tiên hơn mọi CV master**.

| # | Nội dung | Ghi trong CV |
|---|---|---|
| 1 | Thực tập FPT Software: 6 tháng, kết thúc tháng 10/2026 | `FPT Software \| Java Developer Intern  May 2026 – Oct 2026`. Tên dự án: **BUHINH** (đã xác nhận). Các CV ghi "BUHINHYO" là sai, phải sửa khi tailor |
| 2 | VNPay | **Bỏ** khỏi mọi CV |
| 3 | META-CXR là **khoá luận tốt nghiệp** (KLTN) | `Graduation thesis • Solo`. Số liệu dùng được: AUROC 0.744 → 0.764 (3.269 study), 166 bbox leak, 78% filler token, **patch cosine 0.674 → −0.014** (✅ `struct/project/_meta/DECISIONS.md:783`), **1,012 pytest tests passed** |
| 3b | CIDEr 0.007 → 0.168 (25 ca), cue precision 18% → 68% | ❌ **Không tìm thấy** trên GitHub, trong `~/Documents/KLTN/results` hay trong bản sao local → **chưa dùng** cho tới khi có nguồn |
| 4 | Chinese app: bạn bè dùng | Ghi `used by friends`, **không** ghi "dozens of real users" |
| 4b | Lensora | `Course project • Team of 4`, lead developer (1 of 2 developers) |
| 5 | BABÉ 26 landing page là **dự án freelance** cho khách hàng thật | Có thể đưa vào CV (Spring Boot + React + GCP production + GitHub Actions + Resend), ghi là `Freelance project` |
| 6 | Tốt nghiệp **Jun 2027**; English **B2, không có chứng chỉ** | `Expected graduation: Jun 2027`; `English: B2 (CEFR) equivalent` (không ghi tên chứng chỉ; bỏ cách ghi "Intermediate") |
| 7 | Personal Productivity Hub, Todo App | **Không** đưa vào CV |
| 8 | Lương mong muốn | **Từ 3.000.000 VND/tháng** (chưa nói Gross hay Net) |
| 9 | Lỗi bảo mật repo `landing-page` (mật khẩu admin trong README, Resend key trong lịch sử git) | Người dùng biết và sẽ tự xử lý sau, không nhắc lại |
| 10 | Đồ án SE104 (`WEB_PROJECT_2025_2026_UIT`): **người dùng tự code backend** Node.js + Express + Sequelize + MySQL (xác nhận 2026-10-29) | Được ghi `Node.js, Express (course project)` trong kỹ năng khi JD cần Node.js |
| 11 | **Đã hoàn thành toàn bộ môn bắt buộc** (xác nhận 2026-10-29) | Có thể ghi `All required coursework completed` ở Education |
| 12 | **Làm full-time được** (xác nhận 2026-10-29) | Không loại các tin yêu cầu full-time chỉ vì đang là sinh viên |

Tự sửa theo repo (người dùng không phản đối): META-CXR **1,012** test (không ghi 565/541); RAG **9 Playwright E2E + 3 unit** (không ghi 14 E2E); ghi **LangChain text splitters** (không ghi LangChain chung chung).
