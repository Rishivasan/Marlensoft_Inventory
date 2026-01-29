// Test file to verify smart pagination logic
void main() {
  print('Testing Smart Pagination Logic');
  print('================================');
  
  // Test different scenarios
  testPagination(totalPages: 6, currentPage: 1);
  testPagination(totalPages: 6, currentPage: 3);
  testPagination(totalPages: 6, currentPage: 6);
  
  print('\n--- Large Dataset Tests ---');
  testPagination(totalPages: 15, currentPage: 1);
  testPagination(totalPages: 15, currentPage: 3);
  testPagination(totalPages: 15, currentPage: 7);
  testPagination(totalPages: 15, currentPage: 12);
  testPagination(totalPages: 15, currentPage: 15);
  
  print('\n--- Very Large Dataset Tests ---');
  testPagination(totalPages: 100, currentPage: 1);
  testPagination(totalPages: 100, currentPage: 50);
  testPagination(totalPages: 100, currentPage: 97);
}

void testPagination({required int totalPages, required int currentPage}) {
  List<int> pages = calculatePagesToShow(totalPages, currentPage);
  String result = '< ${pages.map((p) => p == -1 ? '...' : p.toString()).join(' ')} >';
  print('Total: $totalPages, Current: $currentPage -> $result');
}

List<int> calculatePagesToShow(int totalPages, int currentPage) {
  List<int> pages = [];
  
  if (totalPages <= 7) {
    // Show all pages if 7 or fewer
    for (int i = 1; i <= totalPages; i++) {
      pages.add(i);
    }
  } else {
    // Smart pagination logic based on current page position
    if (currentPage <= 4) {
      // Near the beginning: 1 2 3 4 5 ... last
      for (int i = 1; i <= 5; i++) {
        pages.add(i);
      }
      pages.add(-1); // ellipsis
      pages.add(totalPages);
    } else if (currentPage >= totalPages - 3) {
      // Near the end: 1 ... (last-4) (last-3) (last-2) (last-1) last
      pages.add(1);
      pages.add(-1); // ellipsis
      for (int i = totalPages - 4; i <= totalPages; i++) {
        pages.add(i);
      }
    } else {
      // In the middle: 1 ... (current-1) current (current+1) ... last
      pages.add(1);
      pages.add(-1); // ellipsis
      for (int i = currentPage - 1; i <= currentPage + 1; i++) {
        pages.add(i);
      }
      pages.add(-1); // ellipsis
      pages.add(totalPages);
    }
  }
  
  return pages;
}