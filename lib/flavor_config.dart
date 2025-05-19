enum Environment { dev, uat, prod }

abstract class AppEnvironment {
  static late String environmentName;
  static late String baseUrl;

  static late Environment _environment;

  static Environment get environment => _environment;
  static void setEnvironment(Environment environment) {
    _environment = environment;
    switch (environment) {
      case Environment.dev:
        environmentName = "Development";
        baseUrl = "https://dev.example.com";
        break;
      case Environment.uat:
        environmentName = "Staging";
        baseUrl = "https://staging.example.com";
        break;
      case Environment.prod:
        environmentName = "Production";
        baseUrl = "https://prod.example.com";
        break;
    }
  }
}
