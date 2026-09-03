import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MorabiYarApp());
}

class MorabiYarApp extends StatelessWidget {
  const MorabiYarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مربی‌یار',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0D12),
        cardTheme: CardThemeData(
          color: const Color(0xFF151821),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF151821),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const GatePage(),
    );
  }
}

class Exercise {
  final String name;
  final String muscle;
  final String equipment;
  final String tip;
  const Exercise(this.name, this.muscle, this.equipment, this.tip);
}

const exercises = <Exercise>[
  Exercise('پرس سینه هالتر', 'سینه', 'هالتر', 'کمر روی نیمکت، تیغه‌های کتف جمع و حرکت کنترل‌شده باشد.'),
  Exercise('پرس سینه دمبل', 'سینه', 'دمبل', 'دمبل‌ها را با کنترل پایین آورده و به‌آرامی بالا ببرید.'),
  Exercise('بارفیکس', 'پشت', 'میله بارفیکس', 'بدن را کنترل کنید و بدون تاب‌دادن بالا بروید.'),
  Exercise('لت سیم‌کش', 'پشت', 'دستگاه سیم‌کش', 'سینه بالا و شانه‌ها پایین نگه داشته شوند.'),
  Exercise('جلو بازو دمبل', 'جلو بازو', 'دمبل', 'آرنج‌ها کنار بدن ثابت بمانند.'),
  Exercise('پشت بازو سیم‌کش', 'پشت بازو', 'سیم‌کش', 'آرنج‌ها ثابت و فقط ساعد حرکت کند.'),
  Exercise('پرس سرشانه دمبل', 'سرشانه', 'دمبل', 'دمبل‌ها را بدون قفل‌کردن شدید آرنج بالا ببرید.'),
  Exercise('نشر جانب', 'سرشانه', 'دمبل', 'حرکت تا حدود ارتفاع شانه و با کنترل انجام شود.'),
  Exercise('اسکوات', 'پا', 'هالتر / وزن بدن', 'زانوها در راستای پنجه و کمر در وضعیت طبیعی باشد.'),
  Exercise('پرس پا', 'پا', 'دستگاه پرس پا', 'حرکت را با دامنه‌ای کنترل‌شده انجام دهید.'),
  Exercise('پشت پا دستگاه', 'همسترینگ', 'دستگاه', 'لگن ثابت و حرکت آهسته باشد.'),
  Exercise('کرانچ شکم', 'شکم', 'وزن بدن', 'گردن را نکشید و حرکت را با انقباض شکم انجام دهید.'),
  Exercise('پلانک', 'شکم', 'وزن بدن', 'بدن در یک خط و شکم فعال باقی بماند.'),
  Exercise('ساق پا ایستاده', 'ساق', 'دستگاه / وزن بدن', 'بالا و پایین‌رفتن کامل و کنترل‌شده انجام شود.'),
];

class Athlete {
  String id;
  String name;
  int age;
  String note;
  Athlete({required this.id, required this.name, required this.age, this.note = ''});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'age': age, 'note': note};
  factory Athlete.fromJson(Map<String, dynamic> j) => Athlete(
    id: j['id'], name: j['name'], age: j['age'], note: j['note'] ?? '',
  );
}

class PlanItem {
  String exercise;
  int reps;
  int sets;
  PlanItem({required this.exercise, required this.reps, required this.sets});

  Map<String, dynamic> toJson() => {'exercise': exercise, 'reps': reps, 'sets': sets};
  factory PlanItem.fromJson(Map<String, dynamic> j) =>
      PlanItem(exercise: j['exercise'], reps: j['reps'], sets: j['sets']);
}

class Store {
  static const athletesKey = 'athletes';
  static const plansKey = 'plans';
  static const passKey = 'master_pass';
  static const activationKey = 'activation_date';

  static Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  static Future<List<Athlete>> athletes() async {
    final p = await prefs;
    return (jsonDecode(p.getString(athletesKey) ?? '[]') as List)
        .map((e) => Athlete.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<void> saveAthletes(List<Athlete> list) async {
    final p = await prefs;
    await p.setString(athletesKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  static Future<Map<String, List<PlanItem>>> plans() async {
    final p = await prefs;
    final raw = jsonDecode(p.getString(plansKey) ?? '{}') as Map;
    return raw.map((k, v) => MapEntry(k, (v as List)
        .map((e) => PlanItem.fromJson(Map<String, dynamic>.from(e))).toList()));
  }

  static Future<void> savePlans(Map<String, List<PlanItem>> plans) async {
    final p = await prefs;
    await p.setString(
  plansKey,
  jsonEncode(
    plans.map(
      (key, value) => MapEntry(
        key,
        value.map((exercise) => exercise.toJson()).toList(),
      ),
    ).toList(),
  ),
);

  }

  static Future<String> password() async {
    final p = await prefs;
    return p.getString(passKey) ?? '1234';
  }

  static Future<void> setPassword(String value) async {
    final p = await prefs;
    await p.setString(passKey, value);
  }

  static Future<DateTime> activationDate() async {
    final p = await prefs;
    final raw = p.getString(activationKey);
    if (raw == null) {
      final now = DateTime.now();
      await p.setString(activationKey, now.toIso8601String());
      return now;
    }
    return DateTime.parse(raw);
  }

  static Future<void> renew() async {
    final p = await prefs;
    await p.setString(activationKey, DateTime.now().toIso8601String());
  }
}

class GatePage extends StatefulWidget {
  const GatePage({super.key});
  @override State<GatePage> createState() => _GatePageState();
}

class _GatePageState extends State<GatePage> {
  final controller = TextEditingController();
  bool loading = true, wrong = false, expired = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final d = await Store.activationDate();
    setState(() {
      loading = false;
      expired = DateTime.now().difference(d).inDays >= 30;
    });
  }

  Future<void> login() async {
    final valid = controller.text == await Store.password();
    if (!valid) {
      setState(() => wrong = true);
      return;
    }
    if (expired) {
      await Store.renew();
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Container(
                  width: 86, height: 86,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF00C2FF)]),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Icon(Icons.fitness_center, size: 44),
                ),
                const SizedBox(height: 20),
                const Text('مربی‌یار', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('مدیریت هوشمند برنامه‌های بدنسازی', textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 36),
                if (expired)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(children: [
                        const Icon(Icons.lock_clock, size: 42),
                        const SizedBox(height: 12),
                        const Text('اشتراک برنامه به پایان رسیده است',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        const SizedBox(height: 8),
                        const Text('برای فعال‌سازی مجدد، رمز اصلی مربی را وارد کنید. با تأیید رمز، اشتراک ۳۰ روزه دوباره فعال می‌شود.',
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
                      ]),
                    ),
                  ),
                const SizedBox(height: 14),
                if (expired)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text('رمز اصلی را برای فعال‌سازی مجدد وارد کنید.',
                        style: TextStyle(color: Colors.white70)),
                  ),
                TextField(
                  controller: controller,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'رمز ورود مربی',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  onSubmitted: (_) => login(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: FilledButton.icon(
                    onPressed: login,
                    icon: const Icon(Icons.login),
                    label: const Text('ورود به برنامه'),
                  ),
                ),
                if (wrong)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('رمز واردشده صحیح نیست.', style: TextStyle(color: Colors.redAccent)),
                  ),
                const SizedBox(height: 18),
                const Text('رمز اولیه: 1234', style: TextStyle(color: Colors.white38)),
                const SizedBox(height: 8),
                const Text('اطلاعات و برنامه‌ها به‌صورت محلی روی همین گوشی ذخیره می‌شوند.',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white30, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  List<Athlete> athletes = [];
  Map<String, List<PlanItem>> plans = {};
  DateTime? activation;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final a = await Store.athletes();
    final p = await Store.plans();
    final d = await Store.activationDate();
    if (mounted) setState(() { athletes = a; plans = p; activation = d; });
  }

  void openAthlete(Athlete a) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) =>
        PlanPage(athlete: a, initial: plans[a.id] ?? [], onSaved: (items) async {
          plans[a.id] = items;
          await Store.savePlans(plans);
          if (mounted) setState(() {});
        })));
  }

  Future<void> addAthlete() async {
    final name = TextEditingController();
    final age = TextEditingController();
    final note = TextEditingController();
    final result = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('ثبت ورزشکار'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'نام و نام خانوادگی')),
        const SizedBox(height: 10),
        TextField(controller: age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سن')),
        const SizedBox(height: 10),
        TextField(controller: note, maxLines: 2, decoration: const InputDecoration(labelText: 'توضیحات (اختیاری)')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ثبت')),
      ],
    ));
    if (result == true && name.text.trim().isNotEmpty) {
      athletes.add(Athlete(id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name.text.trim(), age: int.tryParse(age.text) ?? 0, note: note.text.trim()));
      await Store.saveAthletes(athletes);
      setState(() {});
    }
  }

  Future<void> deleteAthlete(Athlete a) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('حذف ورزشکار'),
      content: Text('«${a.name}» حذف شود؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('خیر')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
      ],
    ));
    if (ok == true) {
      athletes.removeWhere((x) => x.id == a.id);
      plans.remove(a.id);
      await Store.saveAthletes(athletes);
      await Store.savePlans(plans);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(athletes: athletes, plans: plans, onOpen: openAthlete),
      ExercisesPage(),
      AthletesPage(athletes: athletes, onAdd: addAthlete, onOpen: openAthlete, onDelete: deleteAthlete),
      SettingsPage(activation: activation, onRefresh: load),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(['داشبورد', 'بانک حرکات', 'ورزشکاران', 'تنظیمات'][tab],
              style: const TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: false,
        ),
        body: pages[tab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'خانه'),
            NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'حرکات'),
            NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'ورزشکاران'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'تنظیمات'),
          ],
        ),
        floatingActionButton: tab == 2 ? FloatingActionButton.extended(
          onPressed: addAthlete, icon: const Icon(Icons.person_add), label: const Text('ورزشکار جدید'),
        ) : null,
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final List<Athlete> athletes;
  final Map<String, List<PlanItem>> plans;
  final void Function(Athlete) onOpen;
  const DashboardPage({super.key, required this.athletes, required this.plans, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final planned = athletes.where((a) => (plans[a.id] ?? []).isNotEmpty).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF21134D), Color(0xFF112F4D)]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('سلام مربی 👋', style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 8),
            Text('برنامه‌های تمرینی را حرفه‌ای مدیریت کن.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          StatCard(title: 'ورزشکاران', value: '${athletes.length}', icon: Icons.people),
          const SizedBox(width: 10),
          StatCard(title: 'برنامه فعال', value: '$planned', icon: Icons.assignment),
        ]),
        const SizedBox(height: 22),
        const Text('ورزشکاران اخیر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (athletes.isEmpty)
          const EmptyState(icon: Icons.person_add_alt, text: 'هنوز ورزشکاری ثبت نشده است.')
        else
          ...athletes.take(5).map((a) => AthleteTile(a: a, hasPlan: (plans[a.id] ?? []).isNotEmpty, onTap: () => onOpen(a))),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const StatCard({super.key, required this.title, required this.value, required this.icon});
  @override Widget build(BuildContext context) => Expanded(
    child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      CircleAvatar(child: Icon(icon, size: 20)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        Text(title, style: const TextStyle(color: Colors.white54)),
      ]),
    ])),
  );
}

class AthleteTile extends StatelessWidget {
  final Athlete a; final bool hasPlan; final VoidCallback onTap;
  const AthleteTile({super.key, required this.a, required this.hasPlan, required this.onTap});
  @override Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Text(a.name.isEmpty ? '?' : a.name[0])),
      title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${a.age} سال • ${hasPlan ? 'برنامه دارد' : 'بدون برنامه'}'),
      trailing: const Icon(Icons.chevron_left),
    ),
  );
}

class AthletesPage extends StatelessWidget {
  final List<Athlete> athletes;
  final VoidCallback onAdd;
  final void Function(Athlete) onOpen, onDelete;
  const AthletesPage({super.key, required this.athletes, required this.onAdd, required this.onOpen, required this.onDelete});
  @override Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('مدیریت ورزشکاران', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      const Text('برای هر ورزشکار برنامه اختصاصی بسازید.', style: TextStyle(color: Colors.white54)),
      const SizedBox(height: 14),
      if (athletes.isEmpty)
        const EmptyState(icon: Icons.people_outline, text: 'برای شروع یک ورزشکار اضافه کنید.')
      else
        ...athletes.map((a) => Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(a.name[0])),
            title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${a.age} سال${a.note.isNotEmpty ? ' • ${a.note}' : ''}'),
            onTap: () => onOpen(a),
            trailing: PopupMenuButton<String>(
              onSelected: (v) { if (v == 'delete') onDelete(a); },
              itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('حذف'))],
            ),
          ),
        )),
    ],
  );
}

class ExercisesPage extends StatefulWidget {
  @override State<ExercisesPage> createState() => _ExercisesPageState();
}
class _ExercisesPageState extends State<ExercisesPage> {
  String query = '';
  String muscle = 'همه';
  @override Widget build(BuildContext context) {
    final muscles = ['همه', ...{for (final e in exercises) e.muscle}];
    final list = exercises.where((e) =>
      (muscle == 'همه' || e.muscle == muscle) &&
      (query.isEmpty || e.name.contains(query))).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(onChanged: (v) => setState(() => query = v),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'جستجوی حرکت...')),
        const SizedBox(height: 12),
        SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal,
          itemCount: muscles.length, separatorBuilder: (_,__) => const SizedBox(width: 8),
          itemBuilder: (_, i) => ChoiceChip(label: Text(muscles[i]), selected: muscle == muscles[i],
            onSelected: (_) => setState(() => muscle = muscles[i])))),
        const SizedBox(height: 14),
        ...list.map((e) => Card(
          child: ListTile(
            leading: Container(width: 48, height: 48,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF00C2FF)])),
              child: const Icon(Icons.fitness_center)),
            title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${e.muscle} • ${e.equipment}'),
            trailing: const Icon(Icons.info_outline),
            onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
              title: Text(e.name),
              content: Text('${e.muscle}\n\nنکته آموزشی:\n${e.tip}'),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('بستن'))],
            )),
          ),
        )),
      ],
    );
  }
}

class PlanPage extends StatefulWidget {
  final Athlete athlete;
  final List<PlanItem> initial;
  final Future<void> Function(List<PlanItem>) onSaved;
  const PlanPage({super.key, required this.athlete, required this.initial, required this.onSaved});
  @override State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late List<PlanItem> items;
  @override void initState() { super.initState(); items = widget.initial.map((e) => PlanItem(exercise: e.exercise, reps: e.reps, sets: e.sets)).toList(); }

  Future<void> addExercise() async {
    Exercise? selected;
    final reps = TextEditingController(text: '12');
    final sets = TextEditingController(text: '3');
    await showDialog(context: context, builder: (_) => StatefulBuilder(builder: (context, setD) => AlertDialog(
      title: const Text('افزودن حرکت'),
      content: SizedBox(width: 360, child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<Exercise>(
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'حرکت از بانک حرکات'),
          items: exercises.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
          onChanged: (v) => setD(() => selected = v),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: reps, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تعداد'))),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: sets, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ست'))),
        ]),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
        FilledButton(onPressed: () {
          if (selected != null) {
            items.add(PlanItem(exercise: selected!.name, reps: int.tryParse(reps.text) ?? 12, sets: int.tryParse(sets.text) ?? 3));
            Navigator.pop(context); setState(() {});
          }
        }, child: const Text('افزودن')),
      ],
    )));
  }

  Future<void> save() async {
    await widget.onSaved(items);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برنامه ذخیره شد.')));
  }

  Future<void> report() async {
    final text = StringBuffer()
      ..writeln('گزارش برنامه تمرینی')
      ..writeln('باشگاه بدنسازی | مربی‌یار')
      ..writeln('--------------------------')
      ..writeln('نام ورزشکار: ${widget.athlete.name}')
      ..writeln('سن: ${widget.athlete.age}')
      ..writeln('')
      ..writeln('حرکات برنامه:');
    for (var i = 0; i < items.length; i++) {
      text.writeln('${i + 1}. ${items[i].exercise}');
      text.writeln('تعداد: ${items[i].reps} | ست: ${items[i].sets}');
      final e = exercises.firstWhere((x) => x.name == items[i].exercise, orElse: () => exercises.first);
      text.writeln('نکته آموزشی: ${e.tip}');
      text.writeln('');
    }
    text.writeln('تاریخ: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/barname_${widget.athlete.name.replaceAll(' ', '_')}.txt');
    await file.writeAsString(text.toString(), flush: true);
    await Share.shareXFiles([XFile(file.path)], text: 'برنامه تمرینی ${widget.athlete.name}');
  }

  @override Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: Text('برنامه ${widget.athlete.name}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
          CircleAvatar(radius: 28, child: Text(widget.athlete.name[0])),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.athlete.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            Text('${widget.athlete.age} سال', style: const TextStyle(color: Colors.white54)),
          ]),
        ]))),
        const SizedBox(height: 14),
        if (items.isEmpty)
          const EmptyState(icon: Icons.playlist_add, text: 'هنوز حرکتی به برنامه اضافه نشده است.')
        else
          ...List.generate(items.length, (i) {
            final item = items[i];
            final e = exercises.firstWhere((x) => x.name == item.exercise);
            return Card(child: ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(item.exercise, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${e.muscle} • ${item.reps} تکرار × ${item.sets} ست'),
              trailing: PopupMenuButton<String>(
                onSelected: (v) { if (v == 'delete') setState(() => items.removeAt(i)); },
                itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('حذف حرکت'))],
              ),
              onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
                title: Text(e.name), content: Text(e.tip),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('بستن'))],
              )),
            ));
          }),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: addExercise, icon: const Icon(Icons.add), label: const Text('افزودن حرکت از بانک')),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: save, icon: const Icon(Icons.save), label: const Text('ذخیره برنامه')),
        const SizedBox(height: 10),
        FilledButton.tonalIcon(onPressed: items.isEmpty ? null : report, icon: const Icon(Icons.description), label: const Text('ساخت و ارسال گزارش متنی')),
      ]),
    ),
  );
}

class SettingsPage extends StatefulWidget {
  final DateTime? activation;
  final Future<void> Function() onRefresh;
  const SettingsPage({super.key, required this.activation, required this.onRefresh});
  @override State<SettingsPage> createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  Future<void> changePassword() async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('تغییر رمز مربی'),
      content: TextField(controller: c, obscureText: true, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'رمز جدید')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
        FilledButton(onPressed: () => Navigator.pop(context, c.text.trim().length >= 4), child: const Text('ذخیره')),
      ],
    ));
    if (ok == true) { await Store.setPassword(c.text.trim()); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رمز تغییر کرد.'))); }
  }

  Future<void> renew() async {
    await Store.renew();
    await widget.onRefresh();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اشتراک برای ۳۰ روز فعال شد.')));
  }

  @override Widget build(BuildContext context) {
    final d = widget.activation;
    final days = d == null ? 30 : (30 - DateTime.now().difference(d).inDays).clamp(0, 30);
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('تنظیمات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 14),
      Card(child: ListTile(
        leading: const Icon(Icons.verified_user),
        title: const Text('اشتراک برنامه'),
        subtitle: Text(days > 0 ? '$days روز باقی مانده' : 'منقضی شده'),
        trailing: FilledButton(onPressed: renew, child: const Text('فعال‌سازی')),
      )),
      Card(child: ListTile(
        leading: const Icon(Icons.password),
        title: const Text('تغییر رمز اصلی'),
        subtitle: const Text('فقط دارنده رمز می‌تواند برنامه‌ها را مدیریت کند.'),
        onTap: changePassword,
        trailing: const Icon(Icons.chevron_left),
      )),
      Card(child: const ListTile(
        leading: Icon(Icons.phone_android),
        title: Text('مربی‌یار نسخه ۱.۰'),
        subtitle: Text('اپلیکیشن محلی مدیریت برنامه تمرینی'),
      )),
      const SizedBox(height: 16),
      const Text('نکته پروژه: اطلاعات این نمونه روی خود گوشی ذخیره می‌شود و برای استفاده عادی به اینترنت یا سرور نیاز ندارد.',
          style: TextStyle(color: Colors.white54, height: 1.6)),
    ]);
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon; final String text;
  const EmptyState({super.key, required this.icon, required this.text});
  @override Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(28), child: Column(children: [
      Icon(icon, size: 48, color: Colors.white38), const SizedBox(height: 10),
      Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
    ])),
  );
}
