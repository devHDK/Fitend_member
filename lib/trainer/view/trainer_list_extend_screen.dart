import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/component/custom_text_form_field.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/trainer/model/trainer_list_extend.dart';
import 'package:fitend_member/trainer/provider/trainer_list_extend_provider.dart';
import 'package:fitend_member/trainer/view/trainer_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';

class TrainerListExtendScreen extends ConsumerStatefulWidget {
  final String phone;

  const TrainerListExtendScreen({
    super.key,
    required this.phone,
  });

  @override
  ConsumerState<TrainerListExtendScreen> createState() =>
      _TrainerListExtendScreenState();
}

class _TrainerListExtendScreenState
    extends ConsumerState<TrainerListExtendScreen> {
  final _searchController = TextEditingController();
  final BehaviorSubject<String> _subject = BehaviorSubject<String>();
  final ScrollController _scrollController = ScrollController();

  TrainerListExtend pstate = TrainerListExtend(data: [], total: 0);
  bool isLoading = false;
  int start = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    _subject.stream
        .debounceTime(const Duration(milliseconds: 800))
        .listen(refetch);
    _scrollController.addListener(listener);
  }

  void _onSearchTextChanged() {
    _subject.add(_searchController.text);
  }

  void refetch(String text) {
    debugPrint("search ===> $text");
    if (text.isNotEmpty) {
      ref.read(trainerListExtendProvider.notifier).paginate(
            isRefetch: true,
            search: text,
          );
    } else {
      ref.read(trainerListExtendProvider.notifier).init();
    }
  }

  void listener() async {
    if (mounted) {
      final provider = ref.read(trainerListExtendProvider.notifier);

      if (_scrollController.offset >
              _scrollController.position.maxScrollExtent - 100 &&
          pstate.data.length < pstate.total) {
        //스크롤을 아래로 내렸을때
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await provider.paginate(start: pstate.data.length, fetchMore: true);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(listener);
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainerListExtendProvider);

    if (state is TrainerListExtendError) {
      if (_searchController.text.isNotEmpty) {
        ref.read(trainerListExtendProvider.notifier).paginate(
              isRefetch: true,
              search: _searchController.text,
            );
      } else {
        ref.read(trainerListExtendProvider.notifier).init();
      }
    }

    pstate = state as TrainerListExtend;
    start = pstate.data.length;

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Pallete.background,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Stack(
              children: [
                CustomTextFormField(
                  onChanged: (value) {
                    _searchController.text = value;
                    setState(() {});
                  },
                  controller: _searchController,
                  fullLabelText:
                      _searchController.text.isNotEmpty ? '' : '닉네임으로 검색',
                  labelText: '',
                  contentPadding: 50,
                  mainColor: Pallete.darkGray,
                  textColor: Pallete.gray,
                  autoFocus: true,
                ),
                Positioned(
                  top: 11,
                  left: 11,
                  child: SvgPicture.asset(SVGConstants.search),
                )
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(
                  height: 25,
                ),
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (index == pstate.data.length &&
                      state.data.length < state.total) {
                    return const SizedBox(
                      height: 48,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Pallete.point,
                        ),
                      ),
                    );
                  } else if (index == pstate.data.length &&
                      state.data.length == state.total) {
                    return const SizedBox();
                  }

                  final model = pstate.data[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                            builder: (context) => TrainerDetailScreen(
                                  phone: widget.phone,
                                  trainerId: model.id,
                                ),
                            fullscreenDialog: true),
                      );
                    },
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CustomNetworkImage(
                              imageUrl:
                                  '${URLConstants.s3Url}${model.profileImage}',
                              width: 48,
                              height: 48,
                              boxFit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                model.nickname,
                                style: h4Headline.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                model.shortIntro,
                                style: s2SubTitle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          SvgPicture.asset(SVGConstants.next)
                        ],
                      ),
                    ),
                  );
                },
                itemCount: pstate.data.length + 1,
              ),
            )
          ],
        ),
      ),
    );
  }
}
