part of 'master_intake_view.dart';

class WitnessConfirmationOverlay extends StatelessWidget {
  const WitnessConfirmationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080, maxHeight: 620),
          child: Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: Consumer<MasterIntakeNotifier>(
              builder: (context, notifier, _) {
                final step = notifier.currentWitnessStep;
                if (step == null) return const SizedBox.shrink(); // adım yoksa (teorik) boş

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(notifier: notifier),
                    const Divider(height: 1),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 3, child: _StepsColumn(notifier: notifier)),
                          const VerticalDivider(width: 1),
                          Expanded(flex: 3, child: _WitnessCandidatesColumn(step: step)),
                          const VerticalDivider(width: 1),
                          Expanded(flex: 3, child: _WitnessLoginColumn(step: step)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    _Footer(notifier: notifier),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.notifier});

  final MasterIntakeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MedSpacing.insetXl,
      child: Row(
        children: [
          Icon(PhosphorIcons.shieldCheck(), color: MedColors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.intake_witness_dialogTitle, style: MedTextStyles.titleMd()), // "ŞAHİT ONAYI GEREKLİ"
                Text(
                  context.l10n.intake_witness_dialogSubtitle(
                    notifier.completedWitnessStepCount,
                    notifier.witnessSteps.length,
                  ),
                  style: MedTextStyles.bodySm(color: MedColors.text3),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: notifier.closeWitnessFlow),
        ],
      ),
    );
  }
}

class _StepsColumn extends StatelessWidget {
  const _StepsColumn({required this.notifier});

  final MasterIntakeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: MedSpacing.insetXl,
          child: Text(context.l10n.intake_witness_stepsHeader, style: MedTextStyles.titleSm(color: MedColors.text3)),
        ),

        Expanded(
          child: ListView.separated(
            itemCount: notifier.witnessSteps.length,
            separatorBuilder: (_, _) => Divider(height: 1),
            itemBuilder: (context, i) {
              final step = notifier.witnessSteps[i];
              final isActive = i == notifier.currentWitnessStepIndex;
              final items = notifier.items.where((it) => step.itemIds.contains(it.id)).toList();

              return Container(
                padding: MedSpacing.insetXl,
                decoration: BoxDecoration(
                  color: step.isCompleted
                      ? MedColors.greenLight
                      : isActive
                      ? MedColors.blueLight
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final it in items)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(it.medicine?.name ?? '—', style: MedTextStyles.bodyMd(weight: FontWeight.bold)),
                                Text(it.medicine?.barcode ?? '—', style: MedTextStyles.monoSm(weight: FontWeight.bold)),
                              ],
                            ),
                            Text(
                              '${it.dosePiece.formatFractional} ${it.medicine?.operationUnitLocalized(context)}',
                              style: MedTextStyles.bodyMd(weight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WitnessCandidatesColumn extends StatelessWidget {
  const _WitnessCandidatesColumn({required this.step});

  final WitnessStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MedSpacing.insetXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.intake_witness_candidatesHeader, style: MedTextStyles.titleSm(color: MedColors.text3)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: step.eligibleWitnesses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final user = step.eligibleWitnesses[i];
                return Container(
                  padding: MedSpacing.insetLg,
                  decoration: BoxDecoration(border: Border.all(color: MedColors.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(user.fullName, style: MedTextStyles.bodyMd(weight: FontWeight.bold))],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WitnessLoginColumn extends StatefulWidget {
  const _WitnessLoginColumn({required this.step});

  final WitnessStep step;

  @override
  State<_WitnessLoginColumn> createState() => _WitnessLoginColumnState();
}

class _WitnessLoginColumnState extends State<_WitnessLoginColumn> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void didUpdateWidget(covariant _WitnessLoginColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _usernameController.clear();
      _passwordController.clear();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final mac = await DeviceInfo.getMacAddress();
    final loginWitness = context.read<WitnessUserLoginUseCase>();

    final result = await loginWitness.call(
      WitnessUserLoginParams(
        email: _usernameController.text.trim(),
        password: _passwordController.text,
        macAddress: mac,
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      ok: (user) {
        if (user == null) return;

        final currentUserId = context.read<AuthNotifier>().currentUser?.id;
        if (currentUserId != null && user.id == currentUserId) {
          MessageUtils.showErrorSnackbar(context, context.l10n.intake_error_selfWitness);
          return;
        }

        context.read<MasterIntakeNotifier>().confirmWitnessForCurrentStep(user);
        MessageUtils.showSuccessSnackbar(context, context.l10n.intake_witness_confirmedMessage(user.fullName));
        _usernameController.clear();
        _passwordController.clear();
      },
      error: (e) => MessageUtils.showErrorSnackbar(context, e.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: MedColors.border),
    );
    return Padding(
      padding: MedSpacing.insetXl,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.intake_witness_loginHeader, style: MedTextStyles.titleSm(color: MedColors.text3)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: context.l10n.auth_emailLabel,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.witnessDialog_usernameRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.l10n.auth_passwordLabel,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.witnessDialog_passwordRequired : null,
              onFieldSubmitted: (_) => _handleLogin(),
            ),
            const SizedBox(height: 16),
            MedRectangleButton(
              label: context.l10n.intake_witness_confirmButton,
              isLoading: _isLoading,
              onTap: () => _isLoading ? null : _handleLogin(),
              suffixIcon: PhosphorIcons.check(),
              foregroundColor: Colors.white,
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.notifier});

  final MasterIntakeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final remaining = notifier.witnessSteps.length - notifier.completedWitnessStepCount;
    return Padding(
      padding: MedSpacing.insetXl,
      child: Row(
        children: [
          MedRectangleButton(
            width: 200,
            label: context.l10n.intake_witness_cancelButton,
            onTap: notifier.closeWitnessFlow,
            backgroundColor: Colors.grey,
            suffixIcon: PhosphorIcons.x(),
            foregroundColor: Colors.white,
            height: 45,
          ),
          const Spacer(),
          Text(
            context.l10n.intake_witness_remainingLabel(remaining),
            style: MedTextStyles.bodySm(color: MedColors.text3),
          ),
          const SizedBox(width: 12),
          MedRectangleButton(
            height: 45,
            width: 200,
            foregroundColor: Colors.white,
            suffixIcon: PhosphorIcons.arrowRight(),
            label: context.l10n.intake_witness_startButton,
            onTap: (notifier.allWitnessStepsCompleted && !notifier.isChecking)
                ? () {
                    notifier.closeWitnessFlow();
                    notifier.startIntake();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
