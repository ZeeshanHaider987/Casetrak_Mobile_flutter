import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/lookups/lookup_keys.dart';
import '../../../core/lookups/lookup_providers.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/widgets/lookup_dropdown.dart';
import '../data/models/client_dto.dart';
import 'client_providers.dart';

class CreateClientWizard extends ConsumerStatefulWidget {
  const CreateClientWizard({super.key});

  @override
  ConsumerState<CreateClientWizard> createState() => _CreateClientWizardState();
}

class _CreateClientWizardState extends ConsumerState<CreateClientWizard> {
  int _step = 0;
  String? _clientTypeId;
  String? _nameTitle;
  String? _industryType;
  String? _addressType;
  String? _country;
  String? _clientGroup;
  String? _department;
  String? _pocList;
  String? _companyClients;
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _companyName = TextEditingController();
  final _trusteeName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  var _submitting = false;
  Map<String, String> _errors = {};

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _companyName.dispose();
    _trusteeName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  String? get _clientTypeLabel {
    final items = ref.read(lookupManagerProvider).get(LookupKeys.clientType);
    for (final item in items) {
      if (item.id == _clientTypeId) return item.label;
    }
    return null;
  }

  void _next() {
    final type = _clientTypeLabel;
    if (_step == 0 && type == null) {
      setState(() => _errors = {'clientType': 'Choose a client type'});
      return;
    }
    if (_step == 1 && !_detailsLookValid(type)) return;
    setState(() {
      _errors = {};
      _step += 1;
    });
  }

  bool _detailsLookValid(String? type) {
    final errors = <String, String>{};
    final email = _email.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      errors['email'] = 'Enter a valid email';
    }
    if (type == 'Individual') {
      if (_firstName.text.trim().isEmpty) errors['firstName'] = 'Enter a first name';
      if (_lastName.text.trim().isEmpty) errors['lastName'] = 'Enter a last name';
    } else if (type == 'Company') {
      if (_companyName.text.trim().isEmpty) errors['companyName'] = 'Enter a company name';
    } else if (type == 'Trustee') {
      if (_trusteeName.text.trim().isEmpty) errors['trusteeName'] = 'Enter the trustee name';
      if (_companyClients == null) errors['companyClients'] = 'Choose a company';
    }
    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  Future<void> _submit({bool force = false}) async {
    final type = _clientTypeLabel;
    if (type == null) return;
    setState(() => _submitting = true);
    try {
      final repo = ref.read(clientRepositoryProvider);
      final created = switch (type) {
        'Company' => await repo.createCompany(_companyRequest(), force: force),
        'Trustee' => await repo.createTrustee(_trusteeRequest(), force: force),
        _ => await repo.createIndividual(_individualRequest(), force: force),
      };
      ref.invalidate(clientListProvider);
      if (mounted) context.go('/clients/success/${created.id}');
    } on InvalidClientException catch (error) {
      if (mounted) {
        setState(() {
          _errors = error.fieldErrors;
          _step = 1;
        });
      }
    } on DuplicateClientException catch (error) {
      if (!mounted) return;
      final action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(error.message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, 'link'), child: const Text('Link')),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'create'),
              child: const Text('Create anyway'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (action == 'link' && error.existingClientId.isNotEmpty) {
        context.go('/clients/${error.existingClientId}');
      } else if (action == 'create') {
        await _submit(force: true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  CreateIndividualClientRequest _individualRequest() {
    return CreateIndividualClientRequest(
      nameTitle: _nameTitle,
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      addressType: _addressType,
      country: _country,
      clientGroup: _clientGroup,
      department: _department,
      pocList: _pocList,
    );
  }

  CreateCompanyClientRequest _companyRequest() {
    return CreateCompanyClientRequest(
      companyName: _companyName.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      industryType: _industryType,
      addressType: _addressType,
      country: _country,
      clientGroup: _clientGroup,
      department: _department,
      pocList: _pocList,
    );
  }

  CreateTrusteeClientRequest _trusteeRequest() {
    return CreateTrusteeClientRequest(
      trusteeName: _trusteeName.text.trim(),
      nameTitle: _nameTitle,
      companyClients: _companyClients,
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      addressType: _addressType,
      country: _country,
      clientGroup: _clientGroup,
      department: _department,
      pocList: _pocList,
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = _clientTypeLabel;
    return Scaffold(
      appBar: AppBar(title: const Text('Create client')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: _step == 2 ? (_submitting ? null : () => _submit()) : _next,
        onStepCancel: _step == 0 ? null : () => setState(() => _step -= 1),
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(_step == 2 ? (_submitting ? 'Saving…' : 'Create') : 'Continue'),
                ),
                if (_step > 0) ...[
                  const SizedBox(width: 8),
                  TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Type'),
            isActive: _step >= 0,
            state: _step > 0 ? StepState.complete : StepState.indexed,
            content: LookupDropdown(
              lookupKey: LookupKeys.clientType,
              label: 'clientType',
              value: _clientTypeId,
              allowClear: false,
              errorText: _errors['clientType'],
              onChanged: (value) => setState(() => _clientTypeId = value),
            ),
          ),
          Step(
            title: const Text('Details'),
            isActive: _step >= 1,
            state: _step > 1 ? StepState.complete : StepState.indexed,
            content: _Details(
              type: type,
              errors: _errors,
              firstName: _firstName,
              lastName: _lastName,
              companyName: _companyName,
              trusteeName: _trusteeName,
              email: _email,
              phone: _phone,
              nameTitle: _nameTitle,
              industryType: _industryType,
              addressType: _addressType,
              country: _country,
              clientGroup: _clientGroup,
              department: _department,
              pocList: _pocList,
              companyClients: _companyClients,
              onNameTitle: (value) => setState(() => _nameTitle = value),
              onIndustryType: (value) => setState(() => _industryType = value),
              onAddressType: (value) => setState(() => _addressType = value),
              onCountry: (value) => setState(() => _country = value),
              onClientGroup: (value) => setState(() => _clientGroup = value),
              onDepartment: (value) => setState(() => _department = value),
              onPocList: (value) => setState(() => _pocList = value),
              onCompanyClients: (value) => setState(() => _companyClients = value),
            ),
          ),
          Step(
            title: const Text('Review'),
            isActive: _step >= 2,
            content: _Review(
              type: type ?? '—',
              lines: _reviewLines(type),
            ),
          ),
        ],
      ),
    );
  }

  List<(String, String)> _reviewLines(String? type) {
    final manager = ref.watch(lookupManagerProvider);
    String label(String key, String? id) => lookupLabel(manager, key, id);
    return [
      ('clientType', type ?? '—'),
      if (type == 'Individual') ('Name', '${_firstName.text} ${_lastName.text}'.trim()),
      if (type == 'Company') ('Company', _companyName.text.trim()),
      if (type == 'Trustee') ('Trustee', _trusteeName.text.trim()),
      ('Email', _email.text.trim()),
      ('Phone', _phone.text.trim()),
      ('nameTitle', label(LookupKeys.nameTitle, _nameTitle)),
      ('industryType', label(LookupKeys.industryType, _industryType)),
      ('addressType', label(LookupKeys.addressType, _addressType)),
      ('country', label(LookupKeys.country, _country)),
      ('clientGroup', label(LookupKeys.clientGroup, _clientGroup)),
      ('department', label(LookupKeys.department, _department)),
      ('pocList', label(LookupKeys.pocList, _pocList)),
      ('companyClients', label(LookupKeys.companyClients, _companyClients)),
    ];
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.type,
    required this.errors,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.trusteeName,
    required this.email,
    required this.phone,
    required this.nameTitle,
    required this.industryType,
    required this.addressType,
    required this.country,
    required this.clientGroup,
    required this.department,
    required this.pocList,
    required this.companyClients,
    required this.onNameTitle,
    required this.onIndustryType,
    required this.onAddressType,
    required this.onCountry,
    required this.onClientGroup,
    required this.onDepartment,
    required this.onPocList,
    required this.onCompanyClients,
  });

  final String? type;
  final Map<String, String> errors;
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController companyName;
  final TextEditingController trusteeName;
  final TextEditingController email;
  final TextEditingController phone;
  final String? nameTitle;
  final String? industryType;
  final String? addressType;
  final String? country;
  final String? clientGroup;
  final String? department;
  final String? pocList;
  final String? companyClients;
  final ValueChanged<String?> onNameTitle;
  final ValueChanged<String?> onIndustryType;
  final ValueChanged<String?> onAddressType;
  final ValueChanged<String?> onCountry;
  final ValueChanged<String?> onClientGroup;
  final ValueChanged<String?> onDepartment;
  final ValueChanged<String?> onPocList;
  final ValueChanged<String?> onCompanyClients;

  @override
  Widget build(BuildContext context) {
    if (type == null) return const Text('Choose a client type first.');
    return Column(
      children: [
        if (type == 'Individual') ...[
          LookupDropdown(
            lookupKey: LookupKeys.nameTitle,
            label: 'nameTitle',
            value: nameTitle,
            errorText: errors['nameTitle'],
            onChanged: onNameTitle,
          ),
          _gap(),
          _text(firstName, 'firstName', errors['firstName']),
          _gap(),
          _text(lastName, 'lastName', errors['lastName']),
        ],
        if (type == 'Company') ...[
          _text(companyName, 'companyName', errors['companyName']),
          _gap(),
          LookupDropdown(
            lookupKey: LookupKeys.industryType,
            label: 'industryType',
            value: industryType,
            errorText: errors['industryType'],
            onChanged: onIndustryType,
          ),
        ],
        if (type == 'Trustee') ...[
          LookupDropdown(
            lookupKey: LookupKeys.nameTitle,
            label: 'nameTitle',
            value: nameTitle,
            onChanged: onNameTitle,
          ),
          _gap(),
          _text(trusteeName, 'trusteeName', errors['trusteeName']),
          _gap(),
          LookupDropdown(
            lookupKey: LookupKeys.companyClients,
            label: 'companyClients',
            value: companyClients,
            allowClear: false,
            errorText: errors['companyClients'],
            onChanged: onCompanyClients,
          ),
        ],
        _gap(),
        _text(email, 'email', errors['email'], keyboard: TextInputType.emailAddress),
        _gap(),
        _text(phone, 'phone', errors['phone'], keyboard: TextInputType.phone),
        _gap(),
        LookupDropdown(
          lookupKey: LookupKeys.addressType,
          label: 'addressType',
          value: addressType,
          onChanged: onAddressType,
        ),
        _gap(),
        LookupDropdown(
          lookupKey: LookupKeys.country,
          label: 'country',
          value: country,
          onChanged: onCountry,
        ),
        _gap(),
        LookupDropdown(
          lookupKey: LookupKeys.clientGroup,
          label: 'clientGroup',
          value: clientGroup,
          onChanged: onClientGroup,
        ),
        _gap(),
        LookupDropdown(
          lookupKey: LookupKeys.department,
          label: 'department',
          value: department,
          onChanged: onDepartment,
        ),
        _gap(),
        LookupDropdown(
          lookupKey: LookupKeys.pocList,
          label: 'pocList',
          value: pocList,
          onChanged: onPocList,
        ),
      ],
    );
  }

  Widget _gap() => const SizedBox(height: 12);

  Widget _text(
    TextEditingController controller,
    String label,
    String? error, {
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, errorText: error),
    );
  }
}

class _Review extends StatelessWidget {
  const _Review({required this.type, required this.lines});

  final String type;
  final List<(String, String)> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Branch: $type', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final line in lines)
          if (line.$2.isNotEmpty && line.$2 != '—')
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('${line.$1}: ${line.$2}'),
            ),
      ],
    );
  }
}
