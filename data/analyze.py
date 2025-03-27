import geopandas as gpd

# Read the FlatGeobuf file
gdf = gpd.read_file("../data/vt-zoning.fgb")

# Calculate total area
total_area = gdf.geometry.area.sum()

# Group by zoning type and calculate percentages
zoning_stats = (gdf.groupby('Type_of_Zoning_District')
                .agg({'geometry': lambda x: sum(item.area for item in x)})
                .rename(columns={'geometry': 'area'})
                .assign(percentage=lambda df: (df['area'] / total_area * 100).round(2))
                .sort_values('percentage', ascending=False))

# Display results
print("\nZoning District Distribution:")
print("-----------------------------")
for idx, row in zoning_stats.iterrows():
    print(f"{idx}: {row['percentage']}%")