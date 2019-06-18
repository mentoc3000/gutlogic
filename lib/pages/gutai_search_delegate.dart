// import 'package:flutter/material.dart';
// import 'package:built_collection/built_collection.dart';
// import '../models/model_interfaces.dart';
// import '../blocs/searchable_bloc.dart';

// class GutAiSearchDelegate extends SearchDelegate {
//   SearchableBloc searchableBloc;
//   final void Function(Searchable) onSelect;

//   GutAiSearchDelegate({this.searchableBloc, this.onSelect});

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }

//   closeSearch(BuildContext context) {
//     searchableBloc.dispose();
//     close(context, null);
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () => closeSearch(context),
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     // if (query.length < 3) {
//     //   return Column(
//     //     mainAxisAlignment: MainAxisAlignment.center,
//     //     children: <Widget>[
//     //       Center(
//     //         child: Text(
//     //           "Search term must be longer than two letters.",
//     //         ),
//     //       )
//     //     ],
//     //   );
//     // }

//     // //Add the search term to the searchBloc.
//     // //The Bloc will then handle the searching and add the results to the searchResults stream.
//     // //This is the equivalent of submitting the search term to whatever search service you are using
//     // InheritedBlocs.of(context)
//     //     .searchBloc
//     //     .searchTerm
//     //     .add(query);
//     searchableBloc.fetchQuery(query);

//     return Column(
//       children: <Widget>[
//         //Build the results based on the searchResults stream in the searchBloc
//         StreamBuilder(
//           stream: searchableBloc.all,
//           builder: (context, AsyncSnapshot<BuiltList<Searchable>> snapshot) {
//             if (!snapshot.hasData) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Center(child: CircularProgressIndicator()),
//                 ],
//               );
//             } else if (snapshot.data.length == 0) {
//               return Column(
//                 children: <Widget>[
//                   Text(
//                     "No Results Found.",
//                   ),
//                 ],
//               );
//             } else {
//               var results = snapshot.data;
//               return ListView.builder(
//                 itemCount: results.length,
//                 shrinkWrap: true,
//                 itemBuilder: (context, index) {
//                   var result = results[index];
//                   return ListTile(
//                       title: Text(result.searchHeading()),
//                       onTap: () {
//                         this.onSelect(result);
//                         closeSearch(context);
//                       });
//                 },
//               );
//             }
//           },
//         ),
//       ],
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     // This method is called everytime the search term changes.
//     // If you want to add search suggestions as the user enters their search term, this is the place to do that.
//     return Column();
//   }

//   @override
//   ThemeData appBarTheme(BuildContext context) {
//     assert(context != null);
//     final ThemeData theme = Theme.of(context);
//     assert(theme != null);
//     return theme;
//   }
// }
