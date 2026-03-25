import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_fontstyle.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/job/job_pages/job_theme/job_themecontroller.dart';
import 'package:lcsjobs/job/job_pages/job_home/job_filter.dart';
import 'package:lcsjobs/job/job_pages/job_home/job_details.dart';

import '../../utils/job_search_controller.dart';

class JobSearch extends StatefulWidget {
  const JobSearch({Key? key}) : super(key: key);

  @override
  State<JobSearch> createState() => _JobSearchState();
}

class _JobSearchState extends State<JobSearch> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());

  final JobSearchController searchController =
  Get.put(JobSearchController());

  final TextEditingController _textController = TextEditingController();

  int selected2 = 0;
  String _lastQuery = "";

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search".tr,
          style: urbanistBold.copyWith(fontSize: 22),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await searchController.refreshCurrentSearch();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width / 36,
              vertical: height / 36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔎 Search box
                TextField(
                  controller: _textController,
                  style: urbanistSemiBold.copyWith(fontSize: 16),
                  onChanged: (value) {
                    setState(() {
                      _lastQuery = value;
                    });
                    searchController.searchJobs(value);
                  },
                  onSubmitted: (value) {
                    setState(() {
                      _lastQuery = value;
                    });
                    searchController.searchJobs(value);
                  },
                  decoration: InputDecoration(
                    hintStyle: urbanistRegular.copyWith(
                      fontSize: 16,
                      color: JobColor.textgray,
                    ),
                    hintText: "Search for a job or company".tr,
                    fillColor: themedata.isdark
                        ? JobColor.lightblack
                        : JobColor.appgray,
                    filled: true,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: height / 36,
                      color: JobColor.textgray,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: InkWell(
                        splashColor: JobColor.transparent,
                        highlightColor: JobColor.transparent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const JobFilter();
                              },
                            ),
                          );
                        },
                        child: Image.asset(
                          JobPngimage.filter,
                          height: height / 36,
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                      const BorderSide(color: JobColor.appcolor),
                    ),
                  ),
                ),

                SizedBox(height: height / 36),

                // 🔹 Header row: results count + sort (dummy for now)
                Obx(() {
                  final count =
                      searchController.searchResults.length;
                  return Row(
                    children: [
                      Text(
                        "$count found".tr,
                        style:
                        urbanistBold.copyWith(fontSize: 18),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: height / 22,
                        width: height / 26,
                        child: PopupMenuButton<int>(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 0,
                              child: Text(
                                "Alphabetical (A to Z)",
                                style: urbanistSemiBold.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 1,
                              child: Text(
                                "Most Relevant",
                                style: urbanistSemiBold.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 2,
                              child: Text(
                                "Highest Salary",
                                style: urbanistSemiBold.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 3,
                              child: Text(
                                "Newly Posted",
                                style: urbanistSemiBold.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 4,
                              child: Text(
                                "Ending Soon",
                                style: urbanistSemiBold.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            // you can implement sorting here later
                          },
                          offset: const Offset(5, 50),
                          color: themedata.isdark
                              ? JobColor.lightblack
                              : JobColor.white,
                          constraints: BoxConstraints(
                            maxWidth: width / 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          icon: Image.asset(
                            JobPngimage.swap,
                            height: height / 36,
                            fit: BoxFit.fitHeight,
                            color: JobColor.appcolor,
                          ),
                          elevation: 2,
                        ),
                      )
                    ],
                  );
                }),

                SizedBox(height: height / 36),

                // 🔹 Result list or empty state
                Obx(() {
                  if (searchController.isLoading.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: height / 10),
                        child:
                        const CircularProgressIndicator(),
                      ),
                    );
                  }

                  final results =
                      searchController.searchResults;

                  // No query yet
                  if (_lastQuery.trim().isEmpty) {
                    return Padding(
                      padding:
                      EdgeInsets.only(top: height / 10),
                      child: Center(
                        child: Text(
                          "Type something to search jobs"
                              .tr,
                          style: urbanistRegular.copyWith(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  // No result
                  if (results.isEmpty) {
                    return Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        SizedBox(height: height / 26),
                        Image.asset(
                          JobPngimage.notfound,
                          height: height / 3.8,
                          fit: BoxFit.fitHeight,
                        ),
                        SizedBox(height: height / 16),
                        Text(
                          "Not_Found".tr,
                          style: urbanistSemiBold.copyWith(
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(height: height / 46),
                        Text(
                          "Sorry, the keyword you entered cannot be found, please check again or search with another keyword."
                              .tr,
                          style: urbanistRegular.copyWith(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }

                  // 🔹 List of found jobs
                  return ListView.separated(
                    itemCount: results.length,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final job = results[index];

                      return Container(
                        width: width / 1,
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(28),
                          border: Border.all(
                            color: themedata.isdark
                                ? JobColor.borderblack
                                : JobColor.bggray,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width / 26,
                            vertical: height / 46,
                          ),
                          child: InkWell(
                            splashColor: JobColor.transparent,
                            highlightColor:
                            JobColor.transparent,
                            onTap: () {
                              setState(() {
                                selected2 = index;
                              });
                              // Go to job details
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return JobDetails(
                                      jobId:
                                      job['job_id'],
                                    );
                                  },
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: height / 12,
                                      width: height / 12,
                                      decoration:
                                      BoxDecoration(
                                        borderRadius:
                                        BorderRadius
                                            .circular(16),
                                        border: Border.all(
                                          color: themedata
                                              .isdark
                                              ? JobColor
                                              .borderblack
                                              : JobColor
                                              .bggray,
                                        ),
                                      ),
                                      child: Padding(
                                        padding:
                                        const EdgeInsets
                                            .all(15),
                                        child: Image.asset(
                                          JobPngimage.logo,
                                          height:
                                          height / 36,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width: width / 26),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width:
                                              width / 1.8,
                                              child: Text(
                                                job['role'] ??
                                                    '',
                                                style: urbanistSemiBold
                                                    .copyWith(
                                                    fontSize:
                                                    20),
                                                maxLines: 1,
                                                overflow:
                                                TextOverflow
                                                    .ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                                width:
                                                width / 56),
                                            Image.asset(
                                              selected2 ==
                                                  index
                                                  ? JobPngimage
                                                  .savefill
                                                  : JobPngimage
                                                  .save,
                                              height: height /
                                                  36,
                                              color: JobColor
                                                  .appcolor,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: height / 80,
                                        ),
                                        Text(
                                          job['company_name'] ??
                                              '',
                                          style: urbanistMedium
                                              .copyWith(
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow
                                              .ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: height / 96,
                                ),
                                Divider(
                                  color: themedata.isdark
                                      ? JobColor.borderblack
                                      : JobColor.bggray,
                                ),
                                SizedBox(
                                  height: height / 96,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: height / 12,
                                      width: height / 12,
                                      decoration:
                                      BoxDecoration(
                                        borderRadius:
                                        BorderRadius
                                            .circular(16),
                                      ),
                                    ),
                                    SizedBox(
                                        width: width / 26),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          "${job['locality'] ?? ''}, ${job['city'] ?? ''}",
                                          style: urbanistMedium
                                              .copyWith(
                                            fontSize: 18,
                                          ),
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow
                                              .ellipsis,
                                        ),
                                        SizedBox(
                                          height:
                                          height / 66,
                                        ),
                                        Text(
                                          "Rs.${job['min_salary']} - Rs.${job['max_salary']} /month"
                                              .tr,
                                          style: urbanistSemiBold
                                              .copyWith(
                                            fontSize: 18,
                                            color: JobColor
                                                .appcolor,
                                          ),
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow
                                              .ellipsis,
                                        ),
                                        SizedBox(
                                          height:
                                          height / 66,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              decoration:
                                              BoxDecoration(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    6),
                                                border:
                                                Border.all(
                                                  color: JobColor
                                                      .textgray,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets
                                                    .symmetric(
                                                  horizontal:
                                                  width /
                                                      26,
                                                  vertical:
                                                  height /
                                                      96,
                                                ),
                                                child: Text(
                                                  job['category'] ??
                                                      "Full Time"
                                                          .tr,
                                                  style: urbanistSemiBold
                                                      .copyWith(
                                                    fontSize: 10,
                                                    color: JobColor
                                                        .textgray,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width:
                                              width / 26,
                                            ),
                                            Container(
                                              decoration:
                                              BoxDecoration(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    6),
                                                border:
                                                Border.all(
                                                  color: JobColor
                                                      .textgray,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets
                                                    .symmetric(
                                                  horizontal:
                                                  width /
                                                      26,
                                                  vertical:
                                                  height /
                                                      96,
                                                ),
                                                child: Text(
                                                  job['experience_type'] ??
                                                      "Onsite"
                                                          .tr,
                                                  style: urbanistSemiBold
                                                      .copyWith(
                                                    fontSize: 10,
                                                    color: JobColor
                                                        .textgray,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: height / 46,
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
