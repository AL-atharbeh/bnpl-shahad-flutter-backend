import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ui.dart';
import '../auth/auth_frame.dart';

const _fields = [
  'legalName',
  'commercialRegistrationNo',
  'tradeLicenseNo',
  'city',
  'ownerNationalId',
  'bankName',
  'bankAccountHolder',
  'iban',
];

/// Once approved these go through an admin, as the server enforces.
const _lockedAfterApproval = {
  'legalName',
  'commercialRegistrationNo',
  'ownerNationalId',
  'bankName',
  'bankAccountHolder',
  'iban',
};

/// API path segment and store column for each document.
const _documents = [
  ('commercial-registration', 'docCommercialRegistration'),
  ('owner-id', 'docOwnerId'),
  ('trade-license', 'docTradeLicense'),
];

/// The merchant application Shahed reviews before a store goes live:
/// business, owner and bank details, documents and the terms.
class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  final _controllers = {for (final f in _fields) f: TextEditingController()};
  final Map<String, bool> _docs = {};
  List<String> _missing = const [];
  String _status = 'pending';
  String? _reviewNote;
  bool _loading = true;
  bool _terms = false;
  String _busy = '';
  String? _error;
  String? _notice;

  bool get _locked => _status == 'approved';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final session = context.read<SessionService>();
    try {
      final results = await Future.wait([
        session.api.store(session.storeId),
        session.api.me(),
      ]);
      final store = results[0];
      final application = results[1]['application'] is Map
          ? Map<String, dynamic>.from(results[1]['application'])
          : const <String, dynamic>{};
      if (!mounted) return;
      setState(() {
        for (final f in _fields) {
          _controllers[f]!.text = store[f]?.toString() ?? '';
        }
        for (final (type, column) in _documents) {
          _docs[type] = (store[column]?.toString() ?? '').isNotEmpty;
        }
        _status = store['status']?.toString() ?? 'pending';
        _missing = (application['missing'] as List? ?? const [])
            .map((e) => e.toString())
            .toList();
        _reviewNote = application['reviewNote']?.toString();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = errorMessage(context, e);
          _loading = false;
        });
      }
    }
  }

  Map<String, dynamic> get _formData => {
    for (final f in _fields)
      if (!_locked || !_lockedAfterApproval.contains(f))
        f: _controllers[f]!.text.trim(),
  };

  Future<void> _save() async {
    final session = context.read<SessionService>();
    setState(() {
      _busy = 'save';
      _error = null;
      _notice = null;
    });
    try {
      await session.api.updateStore(session.storeId, _formData);
      await _load();
      if (mounted) setState(() => _notice = context.trNow('draftSaved'));
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _busy = '');
    }
  }

  Future<void> _submit() async {
    final session = context.read<SessionService>();
    setState(() {
      _busy = 'submit';
      _error = null;
      _notice = null;
    });
    try {
      await session.api.updateStore(session.storeId, _formData);
      await session.api.submitApplication(session.storeId);
      if (!mounted) return;
      showToast(context, context.trNow('applicationSent'));
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      final missing = e.body is Map ? (e.body as Map)['missing'] : null;
      if (!mounted) return;
      setState(() {
        if (missing is List) {
          _missing = missing.map((m) => m.toString()).toList();
          _error = context.trNow('applicationIncomplete');
        } else {
          _error = errorMessage(context, e);
        }
      });
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _busy = '');
    }
  }

  Future<void> _pickDocument(String type) async {
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (value, icon, label) in [
                ('camera', Icons.photo_camera_rounded, context.tr('takePhoto')),
                (
                  'gallery',
                  Icons.photo_library_rounded,
                  context.tr('chooseFromGallery'),
                ),
                ('file', Icons.picture_as_pdf_rounded, context.tr('pickFile')),
              ])
                ListTile(
                  onTap: () => Navigator.pop(context, value),
                  leading: Icon(icon, color: AppColors.primary),
                  title: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;

    String? path;
    if (source == 'file') {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );
      path = files.isEmpty ? null : files.single.path;
    } else {
      final image = await ImagePicker().pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 2200,
        maxHeight: 2200,
        imageQuality: 85,
      );
      path = image?.path;
    }
    if (path == null || !mounted) return;

    final session = context.read<SessionService>();
    setState(() {
      _busy = type;
      _error = null;
    });
    try {
      await session.api.uploadDocument(session.storeId, type, path);
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _busy = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: Text(context.tr('applicationTitle')),
      ),
      body: _loading
          ? const LoadingState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Text(
                  context.tr('applicationSubtitle'),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                if (_status == 'rejected' && (_reviewNote ?? '').isNotEmpty)
                  _Banner(
                    color: AppColors.error,
                    icon: Icons.info_outline_rounded,
                    title: context.tr('rejectionReason'),
                    text: _reviewNote!,
                  ),
                if (_locked)
                  _Banner(
                    color: AppColors.success,
                    icon: Icons.verified_user_outlined,
                    text: context.tr('applicationLocked'),
                  ),
                if (_error != null) FormErrorBanner(_error!),
                _section(Icons.business_rounded, 'appBusiness', [
                  _field('legalName'),
                  _field('commercialRegistrationNo', ltr: true, number: true),
                  _field('tradeLicenseNo', ltr: true),
                  _field('city'),
                ]),
                _section(Icons.badge_outlined, 'appOwner', [
                  _field(
                    'ownerNationalId',
                    ltr: true,
                    number: true,
                    hint: '9871234567',
                  ),
                ]),
                _section(Icons.account_balance_outlined, 'appBank', [
                  _field('bankName'),
                  _field('bankAccountHolder'),
                  _field(
                    'iban',
                    ltr: true,
                    hint: 'JO94 CBJO 0010 0000 0000 0131 0003 02',
                    help: context.tr('ibanHint'),
                  ),
                ]),
                _section(Icons.description_outlined, 'appDocuments', [
                  for (final (type, column) in _documents)
                    _document(type, column),
                ]),
                if (_notice != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _notice!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (!_locked) ...[
                  CheckboxListTile(
                    value: _terms,
                    onChanged: (v) => setState(() => _terms = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    title: Text(
                      context.tr('acceptTerms'),
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                    subtitle: Text(
                      '${context.tr('readTerms')}: shahedapp.com/terms',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _busy.isEmpty ? _save : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.green100),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _busy == 'save'
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.tr('saveDraft')),
                  ),
                ],
              ],
            ),
      bottomNavigationBar: _loading || _locked
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryButton(
                label: context.tr('submitApplication'),
                icon: Icons.send_rounded,
                isLoading: _busy == 'submit',
                onPressed: _busy.isEmpty && _terms ? _submit : null,
              ),
            ),
    );
  }

  Widget _section(IconData icon, String titleKey, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  context.tr(titleKey),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _field(
    String name, {
    bool ltr = false,
    bool number = false,
    String? hint,
    String? help,
  }) {
    final flagged = _missing.contains(name);
    final disabled = _locked && _lockedAfterApproval.contains(name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr(name),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                if (flagged && _controllers[name]!.text.isNotEmpty)
                  Text(
                    context.tr('invalidValue'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
          ),
          TextField(
            controller: _controllers[name],
            enabled: !disabled,
            textDirection: ltr ? TextDirection.ltr : null,
            keyboardType: number ? TextInputType.number : TextInputType.text,
            textCapitalization: name == 'iban'
                ? TextCapitalization.characters
                : TextCapitalization.none,
            decoration: InputDecoration(
              hintText: hint,
              enabledBorder: flagged
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.error),
                    )
                  : null,
            ),
          ),
          if (help != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4, top: 6),
              child: Text(
                help,
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ),
        ],
      ),
    );
  }

  Widget _document(String type, String column) {
    final uploaded = _docs[type] ?? false;
    final flagged = _missing.contains(column);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: flagged ? AppColors.error : AppColors.hairline,
        ),
      ),
      child: Row(
        children: [
          Icon(
            uploaded ? Icons.check_circle_rounded : Icons.upload_file_rounded,
            color: uploaded ? AppColors.success : AppColors.textHint,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(column),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
                Text(
                  context.tr(uploaded ? 'uploaded' : 'docHint'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          if (!_locked)
            _busy == type
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: _busy.isEmpty ? () => _pickDocument(type) : null,
                    child: Text(context.tr(uploaded ? 'replace' : 'upload')),
                  ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.color,
    required this.icon,
    required this.text,
    this.title,
  });

  final Color color;
  final IconData icon;
  final String text;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(fontWeight: FontWeight.w800, color: color),
                  ),
                Text(text, style: TextStyle(height: 1.5, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
