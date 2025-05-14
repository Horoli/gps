part of FlightSteps;

class StreamExceptionWidgets {
  static Widget waiting({
    required BuildContext context,
  }) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  static Widget hasError({
    required BuildContext context,
    VoidCallback? refreshPressed,
  }) {
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
            '데이터를 불러오는 중 오류가 발생했습니다',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: refreshPressed,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  static Widget noData({required BuildContext context, required String title}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.blue,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
          ElevatedButton(
            child: Text('작업목록으로 가기'),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(PATH.ROUTE_WORKLIST);
            },
          ),
        ],
      ),
    );
  }
}
