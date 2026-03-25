import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
//
// class JobSearchController extends GetxController {
//   final database = FirebaseDatabase.instanceFor(
//     app: Firebase.app(),
//     databaseURL: 'https://lcsjobs-default-rtdb.asia-southeast1.firebasedatabase.app',
//   ).ref();
//
//   final RxList<Map<String, dynamic>> searchResults =
//       <Map<String, dynamic>>[].obs;
//   final RxBool isLoading = false.obs;
//
//   Future<void> searchJobs(String query) async {
//     final trimmed = query.trim();
//
//     if (trimmed.isEmpty) {
//       searchResults.clear();
//       return;
//     }
//
//     isLoading.value = true;
//
//     try {
//       // Get a pool of recent jobs to search within
//       final snapshot = await database
//           .child("jobs")
//           .orderByChild("posted_on")
//           .limitToLast(200)
//           .get();
//
//       if (!snapshot.exists || snapshot.value == null) {
//         searchResults.clear();
//         return;
//       }
//
//       final raw = Map<String, dynamic>.from(snapshot.value as Map);
//       final lowerQuery = trimmed.toLowerCase();
//
//       final List<Map<String, dynamic>> allJobs = raw.entries.map((e) {
//         final job = Map<String, dynamic>.from(e.value as Map);
//         job["key"] = e.key;
//         return job;
//       }).toList();
//
//       final filtered = allJobs
//       // Only approved jobs
//           .where((job) => job["isapproved"] == true)
//       // Match in multiple fields
//           .where((job) {
//         final role =
//         (job["role"] ?? "").toString().toLowerCase();
//         final company =
//         (job["company_name"] ?? "").toString().toLowerCase();
//         final city =
//         (job["city"] ?? "").toString().toLowerCase();
//         final locality =
//         (job["locality"] ?? "").toString().toLowerCase();
//         final category =
//         (job["category"] ?? "").toString().toLowerCase();
//
//         return role.contains(lowerQuery) ||
//             company.contains(lowerQuery) ||
//             city.contains(lowerQuery) ||
//             locality.contains(lowerQuery) ||
//             category.contains(lowerQuery);
//       }).toList();
//
//       // Sort by posted_on (newest first, ISO-8601 string)
//       filtered.sort((a, b) {
//         final pa = (a["posted_on"] ?? "") as String;
//         final pb = (b["posted_on"] ?? "") as String;
//         return pb.compareTo(pa);
//       });
//
//       searchResults.value = filtered;
//     } catch (e) {
//       print("Error searching jobs: $e");
//       searchResults.clear();
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> refreshCurrentSearch(String query) async {
//     await searchJobs(query);
//   }
// }


class JobSearchController extends GetxController {
    final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://lcsjobs-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  /// Current search text
  final RxString currentQuery = ''.obs;

  /// 🔹 Filters
  final RxString filterLocation = ''.obs;        // city/locality text
  final RxInt filterMinSalary = 0.obs;           // in Rs
  final RxInt filterMaxSalary = 200000.obs;      // in Rs
  final RxBool filterWorkFromHomeOnly = false.obs;
  final RxString filterExperienceType = ''.obs;  // "Experienced Only", "Fresher", etc.
  final RxString filterCategory = ''.obs;        // accounting, sales, etc.
    final RxString filterQualification = ''.obs;
    final RxString filterGender = ''.obs;
    RxList<String> filterSkills = <String>[].obs;


  Future<void> searchJobs(String query) async {
    final trimmed = query.trim();
    currentQuery.value = trimmed;  // keep for re-run after filter changes

    if (trimmed.isEmpty && _noActiveFilters) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;

    try {
      // Get a pool of recent jobs
      final snapshot = await database
          .child("jobs")
          .orderByChild("posted_on")
          .limitToLast(200)
          .get();

      if (!snapshot.exists || snapshot.value == null) {
        searchResults.clear();
        return;
      }

      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      final lowerQuery = trimmed.toLowerCase();
      final locFilter = filterLocation.value.trim().toLowerCase();
      final minSal = filterMinSalary.value;
      final maxSal = filterMaxSalary.value;
      final wfHomeOnly = filterWorkFromHomeOnly.value;
      final expFilter = filterExperienceType.value.trim().toLowerCase();
      final catFilter = filterCategory.value.trim().toLowerCase();

      final List<Map<String, dynamic>> allJobs = raw.entries.map((e) {
        final job = Map<String, dynamic>.from(e.value as Map);
        job["key"] = e.key;
        return job;
      }).toList();

      final filtered = allJobs
      // approved only
          .where((job) => job["isapproved"] == true)
      // 🔎 text search (optional if query not empty)
          .where((job) {
        if (lowerQuery.isEmpty) return true;
        final role =
        (job["role"] ?? "").toString().toLowerCase();
        final company =
        (job["company_name"] ?? "").toString().toLowerCase();
        final city =
        (job["city"] ?? "").toString().toLowerCase();
        final locality =
        (job["locality"] ?? "").toString().toLowerCase();
        final category =
        (job["category"] ?? "").toString().toLowerCase();

        return role.contains(lowerQuery) ||
            company.contains(lowerQuery) ||
            city.contains(lowerQuery) ||
            locality.contains(lowerQuery) ||
            category.contains(lowerQuery);
      })
      // 📍 location filter
          .where((job) {
        if (locFilter.isEmpty) return true;
        final city =
        (job["city"] ?? "").toString().toLowerCase();
        final locality =
        (job["locality"] ?? "").toString().toLowerCase();
        return city.contains(locFilter) ||
            locality.contains(locFilter);
      })
      // 💰 salary filter
          .where((job) {
        final jobMin = (job["min_salary"] ?? 0) as int;
        final jobMax = (job["max_salary"] ?? jobMin) as int;
        // overlap check between [jobMin, jobMax] and [minSal, maxSal]
        final overlap = jobMax >= minSal && jobMin <= maxSal;
        return overlap;
      })
      // 🏡 work from home filter
          .where((job) {
        if (!wfHomeOnly) return true;
        return job["work_from_home"] == true;
      })
      // 🧑‍💼 experience type filter
          .where((job) {
        if (expFilter.isEmpty) return true;
        final expType =
        (job["experience_type"] ?? "").toString().toLowerCase();
        return expType.contains(expFilter);
      })
      // 🏷 category filter
          .where((job) {
        if (catFilter.isEmpty) return true;
        final category =
        (job["category"] ?? "").toString().toLowerCase();
        return category.contains(catFilter);
      })
          .toList();

      // Sort by posted_on (newest first, ISO-8601 string)
      filtered.sort((a, b) {
        final pa = (a["posted_on"] ?? "") as String;
        final pb = (b["posted_on"] ?? "") as String;
        return pb.compareTo(pa);
      });

      searchResults.value = filtered;
    } catch (e) {
      print("Error searching jobs: $e");
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  bool get _noActiveFilters =>
      filterLocation.value.trim().isEmpty &&
          !filterWorkFromHomeOnly.value &&
          filterExperienceType.value.trim().isEmpty &&
          filterCategory.value.trim().isEmpty &&
          filterMinSalary.value == 0 &&
          filterMaxSalary.value == 200000;

  Future<void> refreshCurrentSearch() async {
    await searchJobs(currentQuery.value);
  }

  void resetFilters() {
    filterLocation.value = '';
    filterMinSalary.value = 0;
    filterMaxSalary.value = 200000;
    filterWorkFromHomeOnly.value = false;
    filterExperienceType.value = '';
    filterCategory.value = '';
  }
}
