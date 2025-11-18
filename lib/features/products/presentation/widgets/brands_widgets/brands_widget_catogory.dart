
  import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart' as products;

import '../../../../../app_palette.dart';
import '../../../../../constant/constant.dart';
import '../../../../../core/utils/api_response.dart';

Widget buildBrandCategoriesSection() {
    return BlocBuilder<products.ProductBloc, products.ProductState>(
      builder: (context, state) {
        if (state.collections.status != Status.completed) {
          return const SizedBox.shrink();
        }

        final collections = state.collections.data ?? [];
        if (collections.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              ConstantWidgets.hight10(context),
              SizedBox(
                height: 120.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/collection_products',
                            arguments: {
                              'collectionHandle': collection.handle,
                              'collectionTitle': collection.title,
                            },
                          );
                        },
                        child: SizedBox(
                          width: 100.w,
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12.r),
                                  ),
                                  child:
                                      collection.imageUrl != null &&
                                              collection.imageUrl!.isNotEmpty
                                          ? CachedNetworkImage(
                                            imageUrl: collection.imageUrl!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            placeholder:
                                                (context, url) => Container(
                                                  color: Colors.grey[200],
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color:
                                                              AppPalette
                                                                  .blueColor,
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                      color: Colors.grey[200],
                                                      child: Icon(
                                                        Icons.category,
                                                        color: Colors.grey,
                                                        size: 30.sp,
                                                      ),
                                                    ),
                                          )
                                          :   SizedBox(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                    Icons.image_search_rounded,
                                                    color: AppPalette.hintColor,
                                                    size: 80.sp,
                                                  ),
                                                  Text(
                                                    collection.title,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }