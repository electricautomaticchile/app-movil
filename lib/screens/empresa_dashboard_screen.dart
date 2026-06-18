import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_provider.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/empresa_api_service.dart';
import '../theme/colors.dart';

class EmpresaDashboardScreen extends StatefulWidget {
  const EmpresaDashboardScreen({super.key});

  @override
  State<EmpresaDashboardScreen> createState() => _EmpresaDashboardScreenState();
}

class _EmpresaDashboardScreenState extends State<EmpresaDashboardScreen> {
  late Future<EmpresaDashboardData> _dashboardFuture;
  int _selectedIndex = 0;

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
    _DashboardSection('estadisticas', 'Estadísticas', Icons.bar_chart_outlined),
    _DashboardSection('usuarios', 'Usuarios', Icons.manage_accounts_outlined),
    _DashboardSection('configuracion', 'Configuración', Icons.tune_outlined),
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Panel Empresa',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
                ).colorScheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              setState(() {
                _dashboardFuture = EmpresaApiService.loadDashboard();
              });
            },
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
              onRetry: () {
                setState(() {
                  _dashboardFuture = EmpresaApiService.loadDashboard();
                });
              },
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const _EmptyState(
              icon: Icons.dashboard_outlined,
              title: 'Sin datos disponibles',
              message: 'Vuelve a actualizar el panel.',
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CompanyHeader(data: data),
                        const SizedBox(height: 14),
                        _SectionTabs(
                          sections: _sections,
                          selectedIndex: _selectedIndex,
                          onSelected: (index) {
                            setState(() => _selectedIndex = index);
                          },
                        ),
                        const SizedBox(height: 18),
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(EmpresaDashboardData data) {
    switch (_sections[_selectedIndex].id) {
      case 'clientes':
        return _ClientesSection(clientes: data.clientes, stats: data.stats);
      case 'dispositivos':
        return _DispositivosSection(
          dispositivos: data.dispositivos,
          stats: data.stats,
        );
      case 'alertas':
        return _AlertasSection(alertas: data.alertas, stats: data.stats);
      case 'soporte':
        return _SoporteSection(tickets: data.tickets, stats: data.stats);
      case 'estadisticas':
        return _EstadisticasSection(data: data);
      case 'usuarios':
        return _UsuariosSection(usuarios: data.usuarios);
      case 'configuracion':
        return _ConfiguracionSection(data: data);
      default:
        return _OverviewSection(data: data);
    }
  }
}

class _DashboardSection {
  final String id;
  final String label;
  final IconData icon;

  const _DashboardSection(this.id, this.label, this.icon);
}

class _CompanyHeader extends StatelessWidget {
  final EmpresaDashboardData data;

  const _CompanyHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final role = user?.role.isNotEmpty == true ? user!.role : 'EMPRESA';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _StatusBadge(label: role, color: AppColors.info),
                    _StatusBadge(
                      label: 'Actualizado ${_time(data.fetchedAt)}',
                      color: AppColors.success,
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

class _SectionTabs extends StatelessWidget {
  final List<_DashboardSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _SectionTabs({
    required this.sections,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final section = sections[index];
          final selected = index == selectedIndex;
          return ChoiceChip(
            selected: selected,
            avatar: Icon(
              section.icon,
              size: 18,
              color: selected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            label: Text(section.label),
            onSelected: (_) => onSelected(index),
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: selected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: _borderColor(context)),
            ),
          );
        },
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  final EmpresaDashboardData data;

  const _OverviewSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final stats = data.stats;
    final clientesActivos = _stat(stats, 'clientesActivos');
    final clientesTotales = _stat(stats, 'clientesTotales');
    final dispositivosActivos = _stat(stats, 'dispositivosActivos');
    final dispositivosTotales = _stat(stats, 'dispositivosTotales');
    final ticketsPendientes = _stat(stats, 'ticketsPendientes');
    final alertasActivas = _stat(stats, 'alertasActivas');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          icon: Icons.dashboard_outlined,
          title: 'Dashboard Empresa',
          subtitle: 'Resumen operativo del servicio',
        ),
        const SizedBox(height: 12),
        _MetricGrid(
          children: [
            _MetricCard(
              title: 'Ingresos mensuales',
              value: _formatMoney(_stat(stats, 'ingresosMensuales')),
              icon: Icons.attach_money,
              color: AppColors.success,
            ),
            _MetricCard(
              title: 'Consumo total',
              value: _formatKwh(_stat(stats, 'consumoTotal')),
              icon: Icons.local_fire_department_outlined,
              color: AppColors.primary,
            ),
            _MetricCard(
              title: 'Alertas activas',
              value: _whole(alertasActivas),
              icon: Icons.warning_amber_outlined,
              color: AppColors.danger,
            ),
            _MetricCard(
              title: 'Tickets pendientes',
              value: _whole(ticketsPendientes),
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
            ),
            _SummaryRow(
              icon: Icons.electrical_services,
              label: 'Dispositivos operativos',
              value:
                  '${_whole(dispositivosActivos)} / ${_whole(dispositivosTotales)}',
              color: AppColors.success,
              progress: _ratio(dispositivosActivos, dispositivosTotales),
            ),
            _SummaryRow(
              icon: Icons.notifications_active_outlined,
              label: 'Alertas por resolver',
              value: _whole(alertasActivas),
              color: AppColors.danger,
              progress: alertasActivas > 0 ? 0.72 : 0,
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

  const _ClientesSection({required this.clientes, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          icon: Icons.groups_2_outlined,
          title: 'Gestión de Clientes',
          subtitle:
              '${_whole(_stat(stats, 'clientesActivos'))} activos de ${_whole(_stat(stats, 'clientesTotales'))}',
        ),
        const SizedBox(height: 12),
        if (clientes.isEmpty)
          const _EmptyState(
            icon: Icons.groups_2_outlined,
            title: 'No hay clientes para mostrar',
            message: 'Cuando existan clientes asociados aparecerán aquí.',
          )
        else
          ...clientes
              .take(20)
              .map(
                (cliente) => _RecordCard(
                  icon: Icons.person_outline,
                  color: _activeColor(_boolValue(cliente, ['activo'])),
                  title: _text(cliente, ['nombre'], fallback: 'Cliente'),
                  subtitle: _text(cliente, [
                    'numeroCliente',
                    'correo',
                  ], fallback: 'Sin número asignado'),
                  badge: _StatusBadge(
                    label: _boolValue(cliente, ['activo'])
                        ? 'Activo'
                        : 'Inactivo',
                    color: _activeColor(_boolValue(cliente, ['activo'])),
                  ),
                  details: [
                    _InfoLine(
                      Icons.email_outlined,
                      _text(cliente, ['correo'], fallback: 'Sin correo'),
                    ),
                    _InfoLine(
                      Icons.location_on_outlined,
                      _text(cliente, [
                        'comuna',
                        'ciudad',
                        'direccion',
                      ], fallback: 'Sin ubicación'),
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}

class _DispositivosSection extends StatelessWidget {
  final List<Map<String, dynamic>> dispositivos;
  final Map<String, dynamic> stats;

  const _DispositivosSection({required this.dispositivos, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          icon: Icons.electrical_services,
          title: 'Dispositivos Activos',
          subtitle:
              '${_whole(_stat(stats, 'dispositivosActivos'))} operativos de ${_whole(_stat(stats, 'dispositivosTotales'))}',
        ),
        const SizedBox(height: 12),
        if (dispositivos.isEmpty)
          const _EmptyState(
            icon: Icons.electrical_services,
            title: 'No hay dispositivos para mostrar',
            message: 'Los medidores y módulos IoT aparecerán aquí.',
          )
        else
          ...dispositivos.take(20).map((dispositivo) {
            final estado = _text(
              dispositivo,
              ['estado'],
              fallback: _boolValue(dispositivo, ['status', 'activo'])
                  ? 'activo'
                  : 'inactivo',
            );
            final lectura = _value(dispositivo, 'ultimaLectura.energy');
            return _RecordCard(
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
              badge: _StatusBadge(label: estado, color: _stateColor(estado)),
              details: [
                _InfoLine(
                  Icons.person_pin_circle_outlined,
                  _text(dispositivo, [
                    'cliente.nombre',
                    'clienteId',
                  ], fallback: 'Sin cliente asignado'),
                ),
                _InfoLine(
                  Icons.bolt_outlined,
                  lectura is num ? _formatKwh(lectura) : 'Sin lectura reciente',
                ),
              ],
            );
          }),
      ],
    );
  }
}

class _AlertasSection extends StatelessWidget {
  final List<Map<String, dynamic>> alertas;
  final Map<String, dynamic> stats;

  const _AlertasSection({required this.alertas, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          icon: Icons.notifications_active_outlined,
          title: 'Alertas del Sistema',
          subtitle: '${_whole(_stat(stats, 'alertasActivas'))} activas',
        ),
        const SizedBox(height: 12),
        if (alertas.isEmpty)
          const _EmptyState(
            icon: Icons.notifications_active_outlined,
            title: 'Sin alertas visibles',
            message: 'Las notificaciones críticas aparecerán en esta sección.',
          )
        else
          ...alertas.take(20).map((alerta) {
            final severidad = _text(alerta, [
              'severidad',
              'tipo',
            ], fallback: 'informativa');
            return _RecordCard(
              icon: Icons.warning_amber_outlined,
              color: _stateColor(severidad),
              title: _text(alerta, ['titulo'], fallback: 'Alerta'),
              subtitle: _text(alerta, ['mensaje'], fallback: 'Sin descripción'),
              badge: _StatusBadge(
                label: severidad,
                color: _stateColor(severidad),
              ),
              details: [
                _InfoLine(
                  Icons.sensors_outlined,
                  _text(alerta, [
                    'dispositivoId',
                    'destinatarioId',
                  ], fallback: 'Sin origen asociado'),
                ),
                _InfoLine(
                  Icons.fact_check_outlined,
                  _boolValue(alerta, ['leida']) ? 'Leída' : 'Pendiente',
                ),
              ],
            );
          }),
      ],
    );
  }
}

class _SoporteSection extends StatelessWidget {
  final List<Map<String, dynamic>> tickets;
  final Map<String, dynamic> stats;

  const _SoporteSection({required this.tickets, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          icon: Icons.support_agent_outlined,
          title: 'Soporte y Tickets',
          subtitle:
              '${_whole(_stat(stats, 'ticketsPendientes'))} pendientes reportados',
        ),
        const SizedBox(height: 12),
        if (tickets.isEmpty)
          const _EmptyState(
            icon: Icons.support_agent_outlined,
            title: 'Sin tickets recientes',
            message: 'Las solicitudes de soporte aparecerán aquí.',
          )
        else
          ...tickets.take(20).map((ticket) {
            final estado = _text(ticket, ['estado'], fallback: 'abierto');
            final prioridad = _text(ticket, ['prioridad'], fallback: 'normal');
            return _RecordCard(
              icon: Icons.confirmation_number_outlined,
              color: _stateColor(prioridad),
              title: _text(ticket, ['titulo'], fallback: 'Ticket'),
              subtitle: _text(ticket, [
                'numeroTicket',
                'categoria',
              ], fallback: 'Sin folio'),
              badge: _StatusBadge(label: estado, color: _stateColor(estado)),
              details: [
                _InfoLine(Icons.flag_outlined, 'Prioridad $prioridad'),
                _InfoLine(
                  Icons.description_outlined,
                  _text(ticket, ['descripcion'], fallback: 'Sin descripción'),
                ),
              ],
            );
          }),
      ],
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
        _SectionTitle(
          icon: Icons.bar_chart_outlined,
          title: 'Estadísticas Avanzadas',
          subtitle: 'Consumo, facturación y operación',
        ),
        const SizedBox(height: 12),
        _MetricGrid(
          children: [
            _MetricCard(
              title: 'Consumo hoy',
              value: _formatKwh(_stat(stats, 'consumoHoy')),
              icon: Icons.today_outlined,
              color: AppColors.primary,
            ),
            _MetricCard(
              title: 'Consumo total',
              value: _formatKwh(_stat(stats, 'consumoTotal')),
              icon: Icons.bolt_outlined,
              color: AppColors.info,
            ),
            _MetricCard(
              title: 'Boletas pendientes',
              value: _whole(_stat(stats, 'boletasPendientes')),
              icon: Icons.receipt_long_outlined,
              color: AppColors.danger,
            ),
            _MetricCard(
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

  const _UsuariosSection({required this.usuarios});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          icon: Icons.manage_accounts_outlined,
          title: 'Usuarios Empresa',
          subtitle: '${usuarios.length} usuarios visibles',
        ),
        const SizedBox(height: 12),
        if (usuarios.isEmpty)
          const _EmptyState(
            icon: Icons.manage_accounts_outlined,
            title: 'Sin usuarios para mostrar',
            message: 'Los usuarios internos aparecerán aquí.',
          )
        else
          ...usuarios
              .take(20)
              .map(
                (usuario) => _RecordCard(
                  icon: Icons.account_circle_outlined,
                  color: _activeColor(_boolValue(usuario, ['activo'])),
                  title: _text(usuario, ['nombre'], fallback: 'Usuario'),
                  subtitle: _text(usuario, [
                    'email',
                    'correo',
                  ], fallback: 'Sin email'),
                  badge: _StatusBadge(
                    label: _text(usuario, ['role'], fallback: 'ROL'),
                    color: AppColors.info,
                  ),
                  details: [
                    _InfoLine(
                      Icons.work_outline,
                      _text(usuario, ['cargo'], fallback: 'Sin cargo'),
                    ),
                    _InfoLine(
                      Icons.verified_user_outlined,
                      _boolValue(usuario, ['activo']) ? 'Activo' : 'Inactivo',
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}

class _ConfiguracionSection extends StatelessWidget {
  final EmpresaDashboardData data;

  const _ConfiguracionSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final healthStatus = _text(data.health, [
      'status',
      'estado',
    ], fallback: data.health.isEmpty ? 'No disponible' : 'OK');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(
          icon: Icons.tune_outlined,
          title: 'Configuración',
          subtitle: 'Empresa, backend y parámetros operativos',
        ),
        const SizedBox(height: 12),
        _RecordCard(
          icon: Icons.apartment_outlined,
          color: AppColors.primary,
          title: user?.nombre.isNotEmpty == true ? user!.nombre : 'Empresa',
          subtitle: user?.correo.isNotEmpty == true
              ? user!.correo
              : 'Correo no disponible',
          badge: _StatusBadge(
            label: user?.activo == false ? 'Inactiva' : 'Activa',
            color: user?.activo == false ? AppColors.danger : AppColors.success,
          ),
          details: [
            _InfoLine(
              Icons.badge_outlined,
              user?.role.isNotEmpty == true ? user!.role : 'Sin rol',
            ),
            _InfoLine(Icons.security_outlined, 'Autenticación con token móvil'),
          ],
        ),
        _RecordCard(
          icon: Icons.cloud_done_outlined,
          color: _stateColor(healthStatus),
          title: 'Estado del backend',
          subtitle: healthStatus,
          badge: _StatusBadge(
            label: healthStatus,
            color: _stateColor(healthStatus),
          ),
          details: [
            _InfoLine(
              Icons.storage_outlined,
              data.health.isEmpty ? 'Health privado no disponible' : 'API OK',
            ),
            _InfoLine(
              Icons.price_change_outlined,
              '${data.tarifas.length} tarifas cargadas',
            ),
          ],
        ),
      ],
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final EmpresaDashboardData data;

  const _RecentActivity({required this.data});

  @override
  Widget build(BuildContext context) {
    final items = <_InfoLine>[
      _InfoLine(
        Icons.person_add_alt_outlined,
        '${data.clientes.length} clientes cargados',
      ),
      _InfoLine(
        Icons.electrical_services,
        '${data.dispositivos.length} dispositivos visibles',
      ),
      _InfoLine(
        Icons.support_agent_outlined,
        '${data.tickets.length} tickets recientes',
      ),
      _InfoLine(
        Icons.notifications_active_outlined,
        '${data.alertas.length} alertas/notificaciones',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad reciente',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InlineInfo(line: item),
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
        final wide = constraints.maxWidth >= 680;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: wide ? 4 : 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: wide ? 1.9 : 1.18,
          children: children,
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: _borderColor(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.68),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperationalSummary extends StatelessWidget {
  final List<_SummaryRow> rows;

  const _OperationalSummary({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor(context)),
      ),
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

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.progress,
  });
}

class _SummaryLine extends StatelessWidget {
  final _SummaryRow row;

  const _SummaryLine({required this.row});

  @override
  Widget build(BuildContext context) {
    return Row(
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    row.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
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
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final _StatusBadge badge;
  final List<_InfoLine> details;

  const _RecordCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: _borderColor(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.64),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                badge,
              ],
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...details.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: _InlineInfo(line: line),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoLine {
  final IconData icon;
  final String text;

  const _InfoLine(this.icon, this.text);
}

class _InlineInfo extends StatelessWidget {
  final _InfoLine line;

  const _InlineInfo({required this.line});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          line.icon,
          size: 16,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.56),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            line.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.64),
            ),
          ),
        ],
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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

Color _borderColor(BuildContext context) {
  return Theme.of(context).dividerColor.withValues(alpha: 0.36);
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
    return AppColors.primary;
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
