part of gps_test;

class MemberListTile extends StatelessWidget {
  final MMember member;
  final bool isSelected;
  final VoidCallback onPressed;

  const MemberListTile({
    super.key,
    required this.member,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 멤버 정보
              Row(
                children: [
                  Text(
                    '이름: ${member.username}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '휴대폰 번호: ${member.phoneNumber}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 선택 버튼
              GestureDetector(
                onTap: onPressed,
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4B5EFC) : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4B5EFC)
                          : const Color(0xFFDDDDDD),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      isSelected ? '선택 완료' : '선택',
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF4B5EFC),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}
