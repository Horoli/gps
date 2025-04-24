part of gps_test;

class ViewChecklist extends StatefulWidget {
  const ViewChecklist({super.key});

  @override
  State<ViewChecklist> createState() => ViewChecklistState();
}

class ViewChecklistState extends State<ViewChecklist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: TITLE.CHECKLIST),
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder(
                future: GServiceChecklist.get(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<MChecklist>> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '오류가 발생했습니다',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {});
                            },
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('체크리스트가 없습니다'),
                    );
                  }

                  final List<MChecklist> checklists = snapshot.data!;

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: checklists.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, int index) {
                      final MChecklist item = checklists[index];
                      return buildChecklistItem(item, index + 1);
                    },
                  );
                }).expand(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // 확인 버튼 기능
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B5EFC), // 파란색 버튼
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChecklistItem(MChecklist item, int number) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 체크리스트 제목
          Text(
            '체크리스트 $number',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // 체크리스트 설명
          Text(
            item.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          // 동의 스위치
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '동의합니다',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: item.value ?? false,
                onChanged: (value) {
                  setState(() {
                    item.value = value;
                  });
                },
                activeColor: const Color.fromARGB(255, 21, 25, 61),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
