import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> resetPassword(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    print("✅ Correo de recuperación enviado exitosamente a: $email");
  } catch (e) {
    print("❌ Error en resetPassword: $e");
    rethrow; // Re-lanzamos el error para que sea manejado en _sendRecoveryEmail
  }
}

class RecuperarPasswordScreen extends StatefulWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  State<RecuperarPasswordScreen> createState() =>
      _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState extends State<RecuperarPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  Widget build(BuildContext context) {
    print('🎨 Construyendo RecuperarPasswordScreen...');
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F4C3A), Color(0xFF1B5E3C), Color(0xFF2E7D32)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // Header con logo
                _buildHeader(),
                // Card del formulario
                _buildRecoveryCard(context),
                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          // Logo animado
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 35,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Recuperar Contraseña',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ingresa tu email para restablecer tu contraseña',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Título del formulario
          const Text(
            'Restablecer Contraseña',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Te enviaremos un enlace a tu email',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          if (_emailSent)
            _buildSuccessMessage()
          else
            _buildRecoveryForm(context),

          const SizedBox(height: 15),

          // Botón para volver al login
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                print('🔙 Volviendo a pantalla de login...');
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Volver al Login',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryForm(BuildContext context) {
    return Column(
      children: [
        // Campo de email
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico',
              labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: Color(0xFF2E7D32),
                size: 18,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 20),

        // Botón de enviar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendRecoveryEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: const Color(0xFF2E7D32).withOpacity(0.5),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Enviar Enlace de Recuperación',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 40),
          const SizedBox(height: 10),
          const Text(
            '¡Email enviado!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hemos enviado un enlace de recuperación a:',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _emailController.text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        children: [
          Text(
            '© 2024 Sistema de Inventario',
            style: TextStyle(fontSize: 9, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRecoveryEmail() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('📧 Iniciando proceso de recuperación de contraseña...');
      print('📧 Email destino: ${_emailController.text}');
      print('🔍 Verificando configuración de Firebase Auth...');

      // Verificar que Firebase Auth esté inicializado
      if (FirebaseAuth.instance == null) {
        throw Exception('FirebaseAuth no está inicializado');
      }

      print('🔄 Llamando a FirebaseAuth.instance.sendPasswordResetEmail()...');
      print('📧 Email a enviar: ${_emailController.text.trim()}');

      // Llamada directa a Firebase Auth para recuperación de contraseña
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      print("✅ Firebase Auth confirmó el envío del correo de recuperación");
      print("📧 Email destino confirmado: ${_emailController.text.trim()}");
      print("⏰ El correo puede tardar hasta 5-10 minutos en llegar");
      print("📨 VERIFICA LA BANDEJA DE SPAM/CORREO NO DESEADO");
      print("🔍 Diagnóstico de Firebase Auth:");
      print("   - Método: sendPasswordResetEmail()");
      print("   - Servicio: Firebase Authentication");
      print("   - Tipo: Password Reset Email");
      print("   - Estado: Firebase reporta éxito en el envío");
      print("🔧 Si no llega el correo, verifica en Firebase Console:");
      print("   1. Ve a Authentication > Templates");
      print("   2. Haz clic en 'Password reset'");
      print(
        "   3. Verifica que el 'Sender name' y 'From email' estén configurados",
      );
      print("   4. El email de remitente DEBE estar verificado en Firebase");
      print("   5. Ve a Authentication > Settings > Authorized domains");
      print("   6. Asegúrate de que tu dominio esté autorizado");

      print('✅ Proceso de recuperación completado según Firebase');
      print(
        '📨 Firebase indica que el email fue enviado a: ${_emailController.text.trim()}',
      );
      print('💡 Notas importantes:');
      print('   - Firebase NO reporta errores, el envío fue exitoso');
      print('   - El problema puede estar en la entrega del correo');
      print('   - Revisa la bandeja de spam cuidadosamente');
      print('   - Los correos de Firebase pueden ser marcados como spam');
      print('   - Verifica que el email exista en tu proyecto de Firebase');

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } catch (e) {
      print('❌ Error al enviar email de recuperación: $e');
      print('🔍 Stack trace: ${e.toString()}');

      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Error al enviar email de recuperación';

      if (e is FirebaseAuthException) {
        print('🔥 FirebaseAuthException código: ${e.code}');
        print('🔥 FirebaseAuthException mensaje: ${e.message}');

        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No existe una cuenta con este email';
            break;
          case 'invalid-email':
            errorMessage = 'Email inválido';
            break;
          case 'user-disabled':
            errorMessage = 'Esta cuenta ha sido deshabilitada';
            break;
          case 'too-many-requests':
            errorMessage = 'Demasiados intentos. Intenta más tarde';
            break;
          case 'missing-android-pkg-name':
            errorMessage = 'Configuración de Android faltante en Firebase';
            break;
          case 'missing-continue-uri':
            errorMessage = 'URI de continuación faltante en Firebase';
            break;
          case 'unauthorized-continue-uri':
            errorMessage = 'URI de continuación no autorizada';
            break;
          default:
            errorMessage = 'Error de Firebase: ${e.code} - ${e.message}';
        }
      } else {
        errorMessage = 'Error general: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
