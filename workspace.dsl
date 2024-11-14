workspace {
  model {
    user = person "Пользователь" "Пользователь трекера задач."
    taskTracker = softwareSystem "Task Tracker" {
      !docs docs/task_tracker_documentation.md
      !adrs adrs
      # Frontend
      vueApp = container "Web Application" "" "Vue.js" {
        tags "web"
      }
      mobileApp = container "Mobile Application" "" "Flutter" {
        tags "mobile"
      }
      # Backend
      backend = group "Backend API" {
        authComponent = container "Authentication Component" "Управляет регистрацией, аутентификацией и авторизацией пользователей." "Python (FastAPI)"
        api = container "Backend API Application" "" "FastAPI+Uvicorn+SQLAlchemy" {
          taskComponent = component "Task Management Component" "Обрабатывает CRUD-операции задач." "Python (FastAPI)"
          userComponent = component "User Management Component" "Обрабатывает CRUD-операции пользователей." "Python (FastAPI)"

          notificationComponent = component "Notification Component" "Управляет созданием и отправкой уведомлений." "Python (FastAPI)"
          subscriptionComponent = component "Subscription Management Component" "Обрабатывает тарифные планы и подписки." "Python (FastAPI)"{
            !docs docs/billing_component_documentation.md
          }
        }
        db = container "PostgreSQL Database" "Хранит данные пользователей и задач." "PostgreSQL" {
          tags "database"
        }
        queue = container "RabbitMQ" "Очередь сообщений для уведомлений." "RabbitMQ" {
          tags "broker"
        }
      }
    }
    paymentSystem = softwareSystem "Payment System" "Внешняя система обработки платежей (например, Stripe/PayPal)." {
      tags "thirdparty-component"
    }
    emailServiceProvider = softwareSystem "Email Service Provider" "Сервис для отправки email-уведомлений (например, SMTP-сервер)." {
      tags "thirdparty-component"
    }
    telegramApi = softwareSystem "Telegram API" "API для отправки сообщений в Telegram." {
      tags "thirdparty-component"
    }
    firebaseService = softwareSystem "Firebase Cloud Messaging" "Сервис для отправки push-уведомлений через Firebase." {
      tags "thirdparty-component"
    }

    user -> vueApp ""
    user -> mobileApp ""
    api -> db "Запросы и хранение данных"
    api -> queue "Отправляет сообщения"
    vueApp -> taskComponent "Запросы CRUD для задач"
    vueApp -> userComponent "Запросы CRUD для пользователей"
    vueApp -> authComponent "Запросы за аутентификацией и авториацией"
    vueApp -> notificationComponent "Запросы на отправку уведомлений"
    vueApp -> subscriptionComponent "Запросы по подпискам"

    mobileApp -> taskComponent "Запросы CRUD для задач"
    mobileApp -> userComponent "Запросы, связанные с пользователями"
    mobileApp -> notificationComponent "Запросы на отправку уведомлений"
    mobileApp -> subscriptionComponent "Запросы по подпискам"

    # Взаимодействие с внешними системами
    notificationComponent -> emailServiceProvider "Отправляет email"
    notificationComponent -> telegramApi "Отправляет сообщения"
    notificationComponent -> firebaseService "Отправляет push-уведомления"
    subscriptionComponent -> paymentSystem "Проводит транзакции"

  }

  views {
    systemContext taskTracker "SystemContextLevel" {
      include *
      autolayout tb
    }

    container taskTracker "ContainerLevel" {
      include *
      exclude element.tag==thirdparty-component
      autolayout lr
    }

    component api "APIComponents" {
      include *
      exclude element.tag==thirdparty-component
      exclude element.tag==mobile
      autolayout tb
    }
    theme default
    styles {
      element "web" {
        shape webbrowser
      }
      element "mobile" {
        shape mobiledeviceportrait
      }
      element "database" {
        shape cylinder
      }
      element "thirdparty-component" {
        background #ffffff
        color #000000
      }
      element "broker" {
        shape pipe
      }
      element "endpoint" {
        shape circle
      }
    }
  }
}