part of '../new_item_facilities_screen.dart';

class NewItemFacilitiesList extends StatelessWidget {
  const NewItemFacilitiesList({
    Key key,
    @required NewItemFacilitiesBloc bloc,
    this.shrinkWrap = true,
  })  : _bloc = bloc,
        super(key: key);

  final NewItemFacilitiesBloc _bloc;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return Material(
          child: BlocBuilder<NewItemFacilitiesBloc, NewItemFacilitiesState>(
          bloc: _bloc,
          builder: (context, state) {
            final List<NewItemFacilities> listItem = state.props[1];
            if (listItem.isEmpty) {
              return Center(child: Text('Tidak Ada Daftar Beli'));
            }
            return ListView.builder(
                shrinkWrap: shrinkWrap,
                physics: ScrollPhysics(),
                itemCount: listItem.length > 10 ? 10 : listItem.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Checkbox(
                      value: listItem[index].isBought,
                      onChanged: (value) {
                        final item = listItem[index];
                        item.isBought = value;
                        _bloc.add(NewItemFacilitiesChangeValue(item));
                      },
                    ),
                    title: Text(listItem[index].name),
                  );
                });
          }),
    );
  }
}