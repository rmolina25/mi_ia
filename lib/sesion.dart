import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main.dart';
import 'recuperar_password.dart';

class SesionScreen extends StatefulWidget {
  const SesionScreen({super.key});

  @override
  State<SesionScreen> createState() => _SesionScreenState();
}

class _SesionScreenState extends State<SesionScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    print('🎨 Construyendo SesionScreen mejorada...');
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
                _buildLoginCard(context),
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
                    Icons.inventory_2,
                    size: 35,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Bienvenido',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sistema de Gestión de Inventario',
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

  Widget _buildLoginCard(BuildContext context) {
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
            'Iniciar Sesión',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ingresa a tu cuenta para continuar',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Campo de email
          _buildTextField(
            controller: _emailController,
            label: 'Correo Electrónico',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),

          // Campo de contraseña
          _buildPasswordField(),
          const SizedBox(height: 15),

          // Recordar contraseña
          Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                    activeColor: const Color(0xFF2E7D32),
                  ),
                  const Text(
                    'Recordar contraseña',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    print('🔗 Olvidé mi contraseña presionado');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecuperarPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Botón de inicio de sesión
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                print('🟢 Iniciando sesión desde SesionScreen...');
                print('📧 Email: ${_emailController.text}');

                // Validar que los campos no estén vacíos
                if (_emailController.text.isEmpty ||
                    _passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingresa email y contraseña'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Iniciar sesión con Firebase Authentication
                  UserCredential userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                  print(
                    '✅ Inicio de sesión exitoso: ${userCredential.user!.uid}',
                  );

                  // Guardar log de login exitoso en Firestore
                  await FirebaseFirestore.instance
                      .collection('logs_login')
                      .add({
                        'uid': userCredential.user!.uid,
                        'email': _emailController.text,
                        'fecha': FieldValue.serverTimestamp(),
                        'tipo': 'inicio_sesion_exitoso',
                        'recordarSesion': _rememberMe,
                      });

                  print('✅ Log de login guardado en Firestore');

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InventoryScreen(),
                    ),
                  );
                } catch (e) {
                  print('❌ Error en inicio de sesión: $e');
                  String errorMessage = 'Error al iniciar sesión';

                  if (e is FirebaseAuthException) {
                    switch (e.code) {
                      case 'user-not-found':
                        errorMessage = 'No existe una cuenta con este email';
                        break;
                      case 'wrong-password':
                        errorMessage = 'Contraseña incorrecta';
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
                      default:
                        errorMessage = 'Error de autenticación: ${e.message}';
                    }
                  }

                  // Mostrar mensaje de error al usuario
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
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
              child: const Text(
                'Iniciar Sesión',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'o',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            ],
          ),
          const SizedBox(height: 15),

          // Botón de inicio de sesión con Google
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _signInWithGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                side: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.g_mobiledata,
                      size: 18,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continuar con Google',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Botón de registro
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                print('🟠 Navegando a registro desde SesionScreen...');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrationScreen(),
                  ),
                );
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
                'Crear Cuenta',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          prefixIcon: Icon(icon, color: const Color(0xFF2E7D32), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
        ),
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Contraseña',
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Color(0xFF2E7D32),
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[500],
              size: 18,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '© 2024 Sistema de Inventario',
            style: TextStyle(fontSize: 9, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.security,
                  color: Colors.white70,
                  size: 14,
                ),
                onPressed: () {
                  print('🔒 Política de privacidad');
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.help_outline,
                  color: Colors.white70,
                  size: 14,
                ),
                onPressed: () {
                  print('❓ Ayuda y soporte');
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.white70,
                  size: 14,
                ),
                onPressed: () {
                  print('ℹ️ Acerca de');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    print('🔵 Iniciando sesión con Google...');

    try {
      // Iniciar el flujo de autenticación con Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print('❌ Usuario canceló el inicio de sesión con Google');
        return;
      }

      // Obtener los detalles de autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crear una credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase con la credencial de Google
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      print(
        '✅ Inicio de sesión con Google exitoso: ${userCredential.user!.uid}',
      );
      print('📧 Email del usuario: ${userCredential.user!.email}');

      // Guardar log de login con Google en Firestore
      await FirebaseFirestore.instance.collection('logs_login').add({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
        'fecha': FieldValue.serverTimestamp(),
        'tipo': 'inicio_sesion_google_exitoso',
        'proveedor': 'google',
      });

      print('✅ Log de login con Google guardado en Firestore');

      // Navegar a la pantalla principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InventoryScreen()),
      );
    } catch (e) {
      print('❌ Error en inicio de sesión con Google: $e');

      String errorMessage = 'Error al iniciar sesión con Google';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage =
                'Ya existe una cuenta con este email usando otro método de inicio de sesión';
            break;
          case 'invalid-credential':
            errorMessage = 'Credencial de Google inválida';
            break;
          case 'operation-not-allowed':
            errorMessage = 'El inicio de sesión con Google no está habilitado';
            break;
          case 'user-disabled':
            errorMessage = 'Esta cuenta ha sido deshabilitada';
            break;
          case 'user-not-found':
            errorMessage = 'No se encontró una cuenta con este email';
            break;
          default:
            errorMessage = 'Error de autenticación con Google: ${e.message}';
        }
      }

      // Mostrar mensaje de error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
