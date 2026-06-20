import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_provider.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/empresa_api_service.dart';
import '../theme/colors.dart';
import '../widgets/enterprise_components.dart';

class EmpresaDashboardScreen extends StatefulWidget {
  const EmpresaDashboardScreen({super.key});

  @override
  State<EmpresaDashboardScreen> createState() => _EmpresaDashboardScreenState();
}

class _EmpresaDashboardScreenState extends State<EmpresaDashboardScreen> {
  late Future<EmpresaDashboardData> _dashboardFuture;
  int _selectedIndex = 0;
  String _query = '';
  String _filter = 'Todos';

  static const _sections = [
    _DashboardSection('dashboard', 'Inicio', Icons.dashboard_outlined),
    _DashboardSection('clientes', 'Clientes', Icons.groups_2_outlined),
    _DashboardSection(
      'dispositivos',
      'Dispositivos',
      Icons.electrical_services,
    ),
    _DashboardSection(
      'alertas',
      'Alertas',
      Icons.notifications_active_outlined,
    ),
    _DashboardSection('soporte', 'Soporte', Icons.support_agent_outlined),
    _DashboardSection('estadisticas', 'Datos', Icons.bar_chart_outlined),
    _DashboardSection('usuarios', 'Usuarios', Icons.manage_accounts_outlined),
    _DashboardSection('configuracion', 'Ajustes', Icons.tune_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _dashboardFuture = EmpresaApiService.loadDashboard();
  }

  Future<void> _refresh() async {
    final future = EmpresaApiService.loadDashboard();
    setState(() => _dashboardFuture = future);
    await future;
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    context.read<UserProvider>().clearUser();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  void _selectSection(int index) {
    if (index < 0 || index >= _sections.length) return;
    setState(() {
      _selectedIndex = index;
      _query = '';
      _filter = 'Todos';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final mobileSelectedIndex = _selectedIndex < 4 ? _selectedIndex : 4;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Panel Empresa'),
            const SizedBox(height: 2),
            Text(
              user?.correo.isNotEmpty == true
                  ? user!.correo
                  : 'Sesión corporativa',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.66),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _refresh,
          ),
          IconButton(
            tooltip: 'Configuración',
            icon: const Icon(Icons.tune_outlined),
            onPressed: () => _selectSection(7),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_outlined),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<EmpresaDashboardData>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && !snapshot.hasData) {
            return _DashboardError(
              message: 'No se pudo cargar el dashboard empresa.',
              onRetry: _refresh,
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const EnterpriseEmptyState(
              icon: Icons.dashboard_outlined,
              title: 'Sin datos disponibles',
              message: 'Vuelve a actualizar el panel.',
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final content = RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    wide ? 24 : 16,
                    12,
                    wide ? 24 : 16,
                    wide ? 28 : 96,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CompanyHeader(data: data),
                        const SizedBox(height: 18),
                        if (_isSearchableSection) ...[
                          _ListControls(
                            query: _query,
                            filter: _filter,
                            filters: _filtersForCurrentSection,
                            onQueryChanged: (value) =>
                                setState(() => _query = value),
                            onFilterChanged: (value) =>
                                setState(() => _filter = value),
                          ),
                          const SizedBox(height: 18),
                        ],
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: KeyedSubtree(
                            key: ValueKey(_sections[_selectedIndex].id),
                            child: _buildSection(data),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              if (!wide) return content;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EnterpriseRail(
                    sections: _sections,
                    selectedIndex: _selectedIndex,
                    onSelected: _selectSection,
                  ),
                  VerticalDivider(
                    width: 1,
                    color: enterpriseBorderColor(context),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: content,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width >= 900
          ? null
          : NavigationBar(
              selectedIndex: mobileSelectedIndex,
              onDestinationSelected: (index) {
                if (index == 4) {
                  _showMoreSections();
                  return;
                }
                _selectSection(index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_2_outlined),
                  selectedIcon: Icon(Icons.groups_2),
                  label: 'Clientes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.electrical_services_outlined),
                  selectedIcon: Icon(Icons.electrical_services),
                  label: 'Equipos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_active_outlined),
                  selectedIcon: Icon(Icons.notifications_active),
                  label: 'Alertas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.more_horiz),
                  selectedIcon: Icon(Icons.more),
                  label: 'Más',
                ),
              ],
            ),
    );
  }

  bool get _isSearchableSection {
    return const {
      'clientes',
      'dispositivos',
      'alertas',
      'soporte',
      'usuarios',
    }.contains(_sections[_selectedIndex].id);
  }

  List<String> get _filtersForCurrentSection {
    switch (_sections[_selectedIndex].id) {
      case 'clientes':
      case 'usuarios':
        return const ['Todos', 'Activos', 'Inactivos'];
      case 'dispositivos':
        return const ['Todos', 'Activos', 'Inactivos', 'Alertas'];
      case 'alertas':
        return const ['Todos', 'Pendientes', 'Leídas', 'Críticas'];
      case 'soporte':
        return const ['Todos', 'Abiertos', 'Pendientes', 'Cerrados'];
      default:
        return const ['Todos'];
    }
  }

  Widget _buildSection(EmpresaDashboardData data) {
    switch (_sections[_selectedIndex].id) {
      case 'clientes':
        return _ClientesSection(
          clientes: _filterClientes(data.clientes),
          stats: data.stats,
          onOpen: _showRecordDetails,
        );
      case 'dispositivos':
        return _DispositivosSection(
          dispositivos: _filterDispositivos(data.dispositivos),
          stats: data.stats,
          onOpen: _showRecordDetails,
        );
      case 'alertas':
        return _AlertasSection(
          alertas: _filterAlertas(data.alertas),
          stats: data.stats,
          onOpen: _showRecordDetails,
        );
      case 'soporte':
        return _SoporteSection(
          tickets: _filterTickets(data.tickets),
          stats: data.stats,
          onOpen: _showRecordDetails,
        );
      case 'estadisticas':
        return _EstadisticasSection(data: data);
      case 'usuarios':
        return _UsuariosSection(
          usuarios: _filterUsuarios(data.usuarios),
          onOpen: _showRecordDetails,
        );
      case 'configuracion':
        return _ConfiguracionSection(data: data);
      default:
        return _OverviewSection(data: data, onSectionSelected: _selectSection);
    }
  }

  List<Map<String, dynamic>> _filterClientes(List<Map<String, dynamic>> items) {
    return items.where((item) {
      final active = _boolValue(item, ['activo']);
      return _matchesQuery(item) &&
          (_filter == 'Todos' ||
              (_filter == 'Activos' && active) ||
              (_filter == 'Inactivos' && !active));
    }).toList();
  }

  List<Map<String, dynamic>> _filterDispositivos(
    List<Map<String, dynamic>> items,
  ) {
    return items.where((item) {
      final estado = _text(
        item,
        ['estado'],
        fallback: _boolValue(item, ['status', 'activo'])
            ? 'activo'
            : 'inactivo',
      ).toLowerCase();
      final active = estado.contains('activo') && !estado.contains('inactivo');
      final alert =
          estado.contains('alert') ||
          estado.contains('error') ||
          estado.contains('offline');
      return _matchesQuery(item) &&
          (_filter == 'Todos' ||
              (_filter == 'Activos' && active) ||
              (_filter == 'Inactivos' && !active) ||
              (_filter == 'Alertas' && alert));
    }).toList();
  }

  List<Map<String, dynamic>> _filterAlertas(List<Map<String, dynamic>> items) {
    return items.where((item) {
      final read = _boolValue(item, ['leida']);
      final severity = _text(item, [
        'severidad',
        'tipo',
      ], fallback: 'informativa').toLowerCase();
      final critical = severity.contains('crit') || severity.contains('alta');
      return _matchesQuery(item) &&
          (_filter == 'Todos' ||
              (_filter == 'Pendientes' && !read) ||
              (_filter == 'Leídas' && read) ||
              (_filter == 'Críticas' && critical));
    }).toList();
  }

  List<Map<String, dynamic>> _filterTickets(List<Map<String, dynamic>> items) {
    return items.where((item) {
      final status = _text(item, ['estado'], fallback: 'abierto').toLowerCase();
      return _matchesQuery(item) &&
          (_filter == 'Todos' ||
              (_filter == 'Abiertos' && status.contains('abierto')) ||
              (_filter == 'Pendientes' && status.contains('pend')) ||
              (_filter == 'Cerrados' &&
                  (status.contains('cerr') || status.contains('resuelto'))));
    }).toList();
  }

  List<Map<String, dynamic>> _filterUsuarios(List<Map<String, dynamic>> items) {
    return items.where((item) {
      final active = _boolValue(item, ['activo']);
      return _matchesQuery(item) &&
          (_filter == 'Todos' ||
              (_filter == 'Activos' && active) ||
              (_filter == 'Inactivos' && !active));
    }).toList();
  }

  bool _matchesQuery(Map<String, dynamic> item) {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return item.values
        .map((value) => value.toString().toLowerCase())
        .join(' ')
        .contains(normalized);
  }

  void _showMoreSections() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            children: [
              Text(
                'Más módulos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (var i = 4; i < _sections.length; i++)
                ListTile(
                  leading: Icon(_sections[i].icon),
                  title: Text(_sections[i].label),
                  selected: _selectedIndex == i,
                  onTap: () {
                    Navigator.pop(context);
                    _selectSection(i);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showRecordDetails({
    required String title,
    required String subtitle,
    required List<EnterpriseInfoLine> details,
    EnterpriseStatusBadge? badge,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.66),
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (badge != null) badge,
                  ],
                ),
                const SizedBox(height: 18),
                for (final line in details)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: EnterpriseInlineInfo(line: line),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

typedef OpenRecord =
    void Function({
      required String title,
      required String subtitle,
      required List<EnterpriseInfoLine> details,
      EnterpriseStatusBadge? badge,
    });

class _DashboardSection {
  final String id;
  final String label;
  final IconData icon;

  const _DashboardSection(this.id, this.label, this.icon);
}

class _EnterpriseRail extends StatelessWidget {
  final List<_DashboardSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _EnterpriseRail({
    required this.sections,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      labelType: NavigationRailLabelType.all,
      minWidth: 96,
      groupAlignment: -0.92,
      destinations: [
        for (final section in sections)
          NavigationRailDestination(
            icon: Icon(section.icon),
            selectedIcon: Icon(section.icon),
            label: Text(section.label),
          ),
      ],
    );
  }
}

class _ListControls extends StatelessWidget {
  final String query;
  final String filter;
  final List<String> filters;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onFilterChanged;

  const _ListControls({
    required this.query,
    required this.filter,
    required this.filters,
    required this.onQueryChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final search = EnterpriseSearchField(
          value: query,
          hint: 'Buscar en este módulo',
          onChanged: onQueryChanged,
        );
        final chips = EnterpriseFilterBar(
          values: filters,
          selected: filter,
          onSelected: onFilterChanged,
        );

        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [search, const SizedBox(height: 10), chips],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            SizedBox(width: 380, child: chips),
          ],
        );
      },
    );
  }
}

class _CompanyHeader extends StatelessWidget {
  final EmpresaDashboardData data;

  const _CompanyHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final role = user?.role.isNotEmpty == true ? user!.role : 'EMPRESA';

    return EnterpriseCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.apartment_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.nombre.isNotEmpty == true ? user!.nombre : 'Empresa',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    EnterpriseStatusBadge(label: role, color: AppColors.info),
                    EnterpriseStatusBadge(
                      label: 'Actualizado ${_time(data.fetchedAt)}',
                      color: AppColors.success,
                    ),
                    if (data.failedModules.isNotEmpty)
                      EnterpriseStatusBadge(
                        label: 'Parcial ${data.failedModules.length}',
                        color: AppColors.warning,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  final EmpresaDashboardData data;
  final ValueChanged<int> onSectionSelected;

  const _OverviewSection({required this.data, required this.onSectionSelected});

  @override
  Widget build(BuildContext context) {
    final stats = data.stats;
    final clientesActivos = _stat(stats, 'clientesActivos');
    final clientesTotales = _stat(stats, 'clientesTotales');
    final dispositivosActivos = _stat(stats, 'dispositivosActivos');
    final dispositivosTotales = _stat(stats, 'dispositivosTotales');
    final alertasActivas = _stat(stats, 'alertasActivas');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EnterpriseSectionHeader(
          icon: Icons.dashboard_outlined,
          title: 'Operación general',
          subtitle: 'Métricas clave y actividad reciente',
          actions: [
            OutlinedButton.icon(
              onPressed: () => onSectionSelected(5),
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Ver datos'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _MetricGrid(
          children: [
            EnterpriseMetricCard(
              title: 'Ingresos mensuales',
              value: _formatMoney(_stat(stats, 'ingresosMensuales')),
              icon: Icons.attach_money,
              color: AppColors.success,
            ),
            EnterpriseMetricCard(
              title: 'Consumo total',
              value: _formatKwh(_stat(stats, 'consumoTotal')),
              icon: Icons.local_fire_department_outlined,
              color: AppColors.primary,
            ),
            EnterpriseMetricCard(
              title: 'Alertas activas',
              value: _whole(alertasActivas),
              icon: Icons.warning_amber_outlined,
              color: AppColors.danger,
            ),
            EnterpriseMetricCard(
              title: 'Tickets pendientes',
              value: _whole(_stat(stats, 'ticketsPendientes')),
              icon: Icons.support_agent_outlined,
              color: AppColors.info,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _OperationalSummary(
          rows: [
            _SummaryRow(
              icon: Icons.groups_2_outlined,
              label: 'Clientes activos',
              value: '${_whole(clientesActivos)} / ${_whole(clientesTotales)}',
              color: AppColors.info,
              progress: _ratio(clientesActivos, clientesTotales),
              onTap: () => onSectionSelected(1),
            ),
            _SummaryRow(
              icon: Icons.electrical_services,
              label: 'Dispositivos operativos',
              value:
                  '${_whole(dispositivosActivos)} / ${_whole(dispositivosTotales)}',
              color: AppColors.success,
              progress: _ratio(dispositivosActivos, dispositivosTotales),
              onTap: () => onSectionSelected(2),
            ),
            _SummaryRow(
              icon: Icons.notifications_active_outlined,
              label: 'Alertas por resolver',
              value: _whole(alertasActivas),
              color: AppColors.danger,
              progress: alertasActivas > 0 ? 0.72 : 0,
              onTap: () => onSectionSelected(3),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _RecentActivity(data: data),
      ],
    );
  }
}

class _ClientesSection extends StatelessWidget {
  final List<Map<String, dynamic>> clientes;
  final Map<String, dynamic> stats;
  final OpenRecord onOpen;

  const _ClientesSection({
    required this.clientes,
    required this.stats,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return _RecordListSection(
      header: EnterpriseSectionHeader(
        icon: Icons.groups_2_outlined,
        title: 'Gestión de clientes',
        subtitle:
            '${_whole(_stat(stats, 'clientesActivos'))} activos de ${_whole(_stat(stats, 'clientesTotales'))}',
      ),
      empty: const EnterpriseEmptyState(
        icon: Icons.groups_2_outlined,
        title: 'No hay clientes para mostrar',
        message: 'Cambia la búsqueda o actualiza el panel.',
      ),
      children: clientes.take(40).map((cliente) {
        final active = _boolValue(cliente, ['activo']);
        final badge = EnterpriseStatusBadge(
          label: active ? 'Activo' : 'Inactivo',
          color: _activeColor(active),
        );
        final details = [
          EnterpriseInfoLine(
            Icons.email_outlined,
            _text(cliente, ['correo'], fallback: 'Sin correo'),
          ),
          EnterpriseInfoLine(
            Icons.phone_outlined,
            _text(cliente, ['telefono'], fallback: 'Sin teléfono'),
          ),
          EnterpriseInfoLine(
            Icons.location_on_outlined,
            _text(cliente, [
              'comuna',
              'ciudad',
              'direccion',
            ], fallback: 'Sin ubicación'),
          ),
        ];
        return EnterpriseRecordCard(
          icon: Icons.person_outline,
          color: _activeColor(active),
          title: _text(cliente, ['nombre'], fallback: 'Cliente'),
          subtitle: _text(cliente, [
            'numeroCliente',
            'correo',
          ], fallback: 'Sin número asignado'),
          badge: badge,
          details: details,
          onTap: () => onOpen(
            title: _text(cliente, ['nombre'], fallback: 'Cliente'),
            subtitle: _text(cliente, ['numeroCliente'], fallback: 'Sin número'),
            details: details,
            badge: badge,
          ),
        );
      }).toList(),
    );
  }
}

class _DispositivosSection extends StatelessWidget {
  final List<Map<String, dynamic>> dispositivos;
  final Map<String, dynamic> stats;
  final OpenRecord onOpen;

  const _DispositivosSection({
    required this.dispositivos,
    required this.stats,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return _RecordListSection(
      header: EnterpriseSectionHeader(
        icon: Icons.electrical_services,
        title: 'Dispositivos y medidores',
        subtitle:
            '${_whole(_stat(stats, 'dispositivosActivos'))} operativos de ${_whole(_stat(stats, 'dispositivosTotales'))}',
      ),
      empty: const EnterpriseEmptyState(
        icon: Icons.electrical_services,
        title: 'No hay dispositivos para mostrar',
        message: 'Cambia la búsqueda o actualiza el panel.',
      ),
      children: dispositivos.take(40).map((dispositivo) {
        final estado = _text(
          dispositivo,
          ['estado'],
          fallback: _boolValue(dispositivo, ['status', 'activo'])
              ? 'activo'
              : 'inactivo',
        );
        final lectura = _value(dispositivo, 'ultimaLectura.energy');
        final badge = EnterpriseStatusBadge(
          label: estado,
          color: _stateColor(estado),
        );
        final details = [
          EnterpriseInfoLine(
            Icons.person_pin_circle_outlined,
            _text(dispositivo, [
              'cliente.nombre',
              'clienteId',
            ], fallback: 'Sin cliente asignado'),
          ),
          EnterpriseInfoLine(
            Icons.bolt_outlined,
            lectura is num ? _formatKwh(lectura) : 'Sin lectura reciente',
          ),
          EnterpriseInfoLine(
            Icons.qr_code_2_outlined,
            _text(dispositivo, [
              'numeroDispositivo',
              'id',
              '_id',
            ], fallback: 'Sin identificador'),
          ),
        ];
        return EnterpriseRecordCard(
          icon: Icons.electric_meter_outlined,
          color: _stateColor(estado),
          title: _text(dispositivo, [
            'nombre',
            'name',
            'numeroDispositivo',
          ], fallback: 'Dispositivo'),
          subtitle: _text(dispositivo, [
            'numeroDispositivo',
            'type',
            'tipo',
          ], fallback: 'Sin identificador'),
          badge: badge,
          details: details,
          onTap: () => onOpen(
            title: _text(dispositivo, [
              'nombre',
              'name',
              'numeroDispositivo',
            ], fallback: 'Dispositivo'),
            subtitle: _text(dispositivo, [
              'numeroDispositivo',
              'type',
              'tipo',
            ], fallback: 'Sin identificador'),
            details: details,
            badge: badge,
          ),
        );
      }).toList(),
    );
  }
}

class _AlertasSection extends StatelessWidget {
  final List<Map<String, dynamic>> alertas;
  final Map<String, dynamic> stats;
  final OpenRecord onOpen;

  const _AlertasSection({
    required this.alertas,
    required this.stats,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return _RecordListSection(
      header: EnterpriseSectionHeader(
        icon: Icons.notifications_active_outlined,
        title: 'Alertas del sistema',
        subtitle: '${_whole(_stat(stats, 'alertasActivas'))} activas',
      ),
      empty: const EnterpriseEmptyState(
        icon: Icons.notifications_active_outlined,
        title: 'Sin alertas visibles',
        message: 'Las notificaciones críticas aparecerán aquí.',
      ),
      children: alertas.take(40).map((alerta) {
        final severidad = _text(alerta, [
          'severidad',
          'tipo',
        ], fallback: 'informativa');
        final badge = EnterpriseStatusBadge(
          label: severidad,
          color: _stateColor(severidad),
        );
        final details = [
          EnterpriseInfoLine(
            Icons.sensors_outlined,
            _text(alerta, [
              'dispositivoId',
              'destinatarioId',
            ], fallback: 'Sin origen asociado'),
          ),
          EnterpriseInfoLine(
            Icons.fact_check_outlined,
            _boolValue(alerta, ['leida']) ? 'Leída' : 'Pendiente',
          ),
          EnterpriseInfoLine(
            Icons.description_outlined,
            _text(alerta, ['mensaje'], fallback: 'Sin descripción'),
          ),
        ];
        return EnterpriseRecordCard(
          icon: Icons.warning_amber_outlined,
          color: _stateColor(severidad),
          title: _text(alerta, ['titulo'], fallback: 'Alerta'),
          subtitle: _text(alerta, ['mensaje'], fallback: 'Sin descripción'),
          badge: badge,
          details: details,
          onTap: () => onOpen(
            title: _text(alerta, ['titulo'], fallback: 'Alerta'),
            subtitle: _text(alerta, ['mensaje'], fallback: 'Sin descripción'),
            details: details,
            badge: badge,
          ),
        );
      }).toList(),
    );
  }
}

class _SoporteSection extends StatelessWidget {
  final List<Map<String, dynamic>> tickets;
  final Map<String, dynamic> stats;
  final OpenRecord onOpen;

  const _SoporteSection({
    required this.tickets,
    required this.stats,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return _RecordListSection(
      header: EnterpriseSectionHeader(
        icon: Icons.support_agent_outlined,
        title: 'Soporte y tickets',
        subtitle:
            '${_whole(_stat(stats, 'ticketsPendientes'))} pendientes reportados',
      ),
      empty: const EnterpriseEmptyState(
        icon: Icons.support_agent_outlined,
        title: 'Sin tickets recientes',
        message: 'Las solicitudes de soporte aparecerán aquí.',
      ),
      children: tickets.take(40).map((ticket) {
        final estado = _text(ticket, ['estado'], fallback: 'abierto');
        final prioridad = _text(ticket, ['prioridad'], fallback: 'normal');
        final badge = EnterpriseStatusBadge(
          label: estado,
          color: _stateColor(estado),
        );
        final details = [
          EnterpriseInfoLine(Icons.flag_outlined, 'Prioridad $prioridad'),
          EnterpriseInfoLine(
            Icons.description_outlined,
            _text(ticket, ['descripcion'], fallback: 'Sin descripción'),
          ),
        ];
        return EnterpriseRecordCard(
          icon: Icons.confirmation_number_outlined,
          color: _stateColor(prioridad),
          title: _text(ticket, ['titulo'], fallback: 'Ticket'),
          subtitle: _text(ticket, [
            'numeroTicket',
            'categoria',
          ], fallback: 'Sin folio'),
          badge: badge,
          details: details,
          onTap: () => onOpen(
            title: _text(ticket, ['titulo'], fallback: 'Ticket'),
            subtitle: _text(ticket, [
              'numeroTicket',
              'categoria',
            ], fallback: 'Sin folio'),
            details: details,
            badge: badge,
          ),
        );
      }).toList(),
    );
  }
}

class _EstadisticasSection extends StatelessWidget {
  final EmpresaDashboardData data;

  const _EstadisticasSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final stats = data.stats;
    final clientesActivos = _stat(stats, 'clientesActivos');
    final clientesTotales = _stat(stats, 'clientesTotales');
    final dispositivosActivos = _stat(stats, 'dispositivosActivos');
    final dispositivosTotales = _stat(stats, 'dispositivosTotales');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EnterpriseSectionHeader(
          icon: Icons.bar_chart_outlined,
          title: 'Datos operativos',
          subtitle: 'Consumo, facturación y disponibilidad',
        ),
        const SizedBox(height: 14),
        _MetricGrid(
          children: [
            EnterpriseMetricCard(
              title: 'Consumo hoy',
              value: _formatKwh(_stat(stats, 'consumoHoy')),
              icon: Icons.today_outlined,
              color: AppColors.primary,
            ),
            EnterpriseMetricCard(
              title: 'Consumo total',
              value: _formatKwh(_stat(stats, 'consumoTotal')),
              icon: Icons.bolt_outlined,
              color: AppColors.info,
            ),
            EnterpriseMetricCard(
              title: 'Boletas pendientes',
              value: _whole(_stat(stats, 'boletasPendientes')),
              icon: Icons.receipt_long_outlined,
              color: AppColors.danger,
            ),
            EnterpriseMetricCard(
              title: 'Tarifas cargadas',
              value: data.tarifas.length.toString(),
              icon: Icons.price_change_outlined,
              color: AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _OperationalSummary(
          rows: [
            _SummaryRow(
              icon: Icons.groups_2_outlined,
              label: 'Penetración de clientes activos',
              value: _percent(_ratio(clientesActivos, clientesTotales)),
              color: AppColors.info,
              progress: _ratio(clientesActivos, clientesTotales),
            ),
            _SummaryRow(
              icon: Icons.electrical_services,
              label: 'Disponibilidad de dispositivos',
              value: _percent(_ratio(dispositivosActivos, dispositivosTotales)),
              color: AppColors.success,
              progress: _ratio(dispositivosActivos, dispositivosTotales),
            ),
          ],
        ),
      ],
    );
  }
}

class _UsuariosSection extends StatelessWidget {
  final List<Map<String, dynamic>> usuarios;
  final OpenRecord onOpen;

  const _UsuariosSection({required this.usuarios, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return _RecordListSection(
      header: EnterpriseSectionHeader(
        icon: Icons.manage_accounts_outlined,
        title: 'Usuarios empresa',
        subtitle: '${usuarios.length} usuarios visibles',
      ),
      empty: const EnterpriseEmptyState(
        icon: Icons.manage_accounts_outlined,
        title: 'Sin usuarios para mostrar',
        message: 'Cambia la búsqueda o actualiza el panel.',
      ),
      children: usuarios.take(40).map((usuario) {
        final active = _boolValue(usuario, ['activo']);
        final badge = EnterpriseStatusBadge(
          label: _text(usuario, ['role'], fallback: 'ROL'),
          color: AppColors.info,
        );
        final details = [
          EnterpriseInfoLine(
            Icons.email_outlined,
            _text(usuario, ['email', 'correo'], fallback: 'Sin email'),
          ),
          EnterpriseInfoLine(
            Icons.work_outline,
            _text(usuario, ['cargo'], fallback: 'Sin cargo'),
          ),
          EnterpriseInfoLine(
            Icons.verified_user_outlined,
            active ? 'Activo' : 'Inactivo',
          ),
        ];
        return EnterpriseRecordCard(
          icon: Icons.account_circle_outlined,
          color: _activeColor(active),
          title: _text(usuario, ['nombre'], fallback: 'Usuario'),
          subtitle: _text(usuario, ['email', 'correo'], fallback: 'Sin email'),
          badge: badge,
          details: details,
          onTap: () => onOpen(
            title: _text(usuario, ['nombre'], fallback: 'Usuario'),
            subtitle: _text(usuario, [
              'email',
              'correo',
            ], fallback: 'Sin email'),
            details: details,
            badge: badge,
          ),
        );
      }).toList(),
    );
  }
}

class _ConfiguracionSection extends StatelessWidget {
  final EmpresaDashboardData data;

  const _ConfiguracionSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final permissions = context.watch<UserProvider>().permissions;
    final healthStatus = _text(data.health, [
      'status',
      'estado',
    ], fallback: data.health.isEmpty ? 'No disponible' : 'OK');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EnterpriseSectionHeader(
          icon: Icons.tune_outlined,
          title: 'Configuración operativa',
          subtitle: 'Empresa, backend, permisos y parámetros',
        ),
        const SizedBox(height: 14),
        EnterpriseRecordCard(
          icon: Icons.apartment_outlined,
          color: AppColors.primary,
          title: user?.nombre.isNotEmpty == true ? user!.nombre : 'Empresa',
          subtitle: user?.correo.isNotEmpty == true
              ? user!.correo
              : 'Correo no disponible',
          badge: EnterpriseStatusBadge(
            label: user?.activo == false ? 'Inactiva' : 'Activa',
            color: user?.activo == false ? AppColors.danger : AppColors.success,
          ),
          details: [
            EnterpriseInfoLine(
              Icons.badge_outlined,
              user?.role.isNotEmpty == true ? user!.role : 'Sin rol',
            ),
            EnterpriseInfoLine(
              Icons.security_outlined,
              permissions.isEmpty
                  ? 'Permisos no informados por sesión'
                  : '${permissions.length} permisos cargados',
            ),
          ],
        ),
        EnterpriseRecordCard(
          icon: Icons.cloud_done_outlined,
          color: _stateColor(healthStatus),
          title: 'Estado del backend',
          subtitle: healthStatus,
          badge: EnterpriseStatusBadge(
            label: healthStatus,
            color: _stateColor(healthStatus),
          ),
          details: [
            EnterpriseInfoLine(
              Icons.storage_outlined,
              data.health.isEmpty ? 'Health privado no disponible' : 'API OK',
            ),
            EnterpriseInfoLine(
              Icons.price_change_outlined,
              '${data.tarifas.length} tarifas cargadas',
            ),
          ],
        ),
      ],
    );
  }
}

class _RecordListSection extends StatelessWidget {
  final EnterpriseSectionHeader header;
  final EnterpriseEmptyState empty;
  final List<Widget> children;

  const _RecordListSection({
    required this.header,
    required this.empty,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 14),
        if (children.isEmpty) empty else ...children,
      ],
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final EmpresaDashboardData data;

  const _RecentActivity({required this.data});

  @override
  Widget build(BuildContext context) {
    final items = <EnterpriseInfoLine>[
      EnterpriseInfoLine(
        Icons.person_add_alt_outlined,
        '${data.clientes.length} clientes cargados',
      ),
      EnterpriseInfoLine(
        Icons.electrical_services,
        '${data.dispositivos.length} dispositivos visibles',
      ),
      EnterpriseInfoLine(
        Icons.support_agent_outlined,
        '${data.tickets.length} tickets recientes',
      ),
      EnterpriseInfoLine(
        Icons.notifications_active_outlined,
        '${data.alertas.length} alertas/notificaciones',
      ),
    ];

    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad reciente',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: EnterpriseInlineInfo(line: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final List<Widget> children;

  const _MetricGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final medium = constraints.maxWidth >= 520;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: wide ? 4 : (medium ? 2 : 1),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: wide ? 1.82 : (medium ? 1.55 : 2.7),
          children: children,
        );
      },
    );
  }
}

class _OperationalSummary extends StatelessWidget {
  final List<_SummaryRow> rows;

  const _OperationalSummary({required this.rows});

  @override
  Widget build(BuildContext context) {
    return EnterpriseCard(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _SummaryLine(row: rows[i]),
            if (i != rows.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double progress;
  final VoidCallback? onTap;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.progress,
    this.onTap,
  });
}

class _SummaryLine extends StatelessWidget {
  final _SummaryRow row;

  const _SummaryLine({required this.row});

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(row.icon, color: row.color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    row.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: row.progress.clamp(0, 1),
                  backgroundColor: row.color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(row.color),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (row.onTap == null) return content;

    return InkWell(
      onTap: row.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: content,
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 44,
              color: AppColors.danger,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

String _time(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

dynamic _value(Map<String, dynamic> item, String path) {
  dynamic current = item;
  for (final part in path.split('.')) {
    if (current is Map && current.containsKey(part)) {
      current = current[part];
    } else {
      return null;
    }
  }
  return current;
}

String _text(
  Map<String, dynamic> item,
  List<String> paths, {
  String fallback = '-',
}) {
  for (final path in paths) {
    final value = _value(item, path);
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return fallback;
}

num _stat(Map<String, dynamic> stats, String key) {
  final value = stats[key];
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

bool _boolValue(Map<String, dynamic> item, List<String> keys) {
  for (final key in keys) {
    final value = _value(item, key);
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == 'activo') return true;
      if (normalized == 'false' || normalized == 'inactivo') return false;
    }
  }
  return false;
}

Color _activeColor(bool active) =>
    active ? AppColors.success : AppColors.danger;

Color _stateColor(String state) {
  final normalized = state.toLowerCase();
  if (normalized.contains('crit') ||
      normalized.contains('alta') ||
      normalized.contains('error') ||
      normalized.contains('inactivo') ||
      normalized.contains('venc')) {
    return AppColors.danger;
  }
  if (normalized.contains('pend') ||
      normalized.contains('medio') ||
      normalized.contains('warning') ||
      normalized.contains('abierto')) {
    return AppColors.warning;
  }
  if (normalized.contains('activo') ||
      normalized.contains('ok') ||
      normalized.contains('resuelto') ||
      normalized.contains('online')) {
    return AppColors.success;
  }
  return AppColors.info;
}

String _formatMoney(num value) {
  return '\$${_formatThousands(value.round())}';
}

String _formatKwh(num value) {
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)} MWh';
  return '${value.toStringAsFixed(1)} kWh';
}

String _formatThousands(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final position = raw.length - i;
    buffer.write(raw[i]);
    if (position > 1 && position % 3 == 1) buffer.write('.');
  }
  return buffer.toString();
}

String _whole(num value) => _formatThousands(value.round());

double _ratio(num value, num total) {
  if (total <= 0) return 0;
  return (value / total).clamp(0, 1).toDouble();
}

String _percent(double ratio) => '${(ratio * 100).round()}%';
