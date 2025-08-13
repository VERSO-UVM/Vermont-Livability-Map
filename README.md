# Vermont Livability Map (BETA)

[Vermont Livability Map Page](https://verso-uvm.github.io/Vermont-Livability-Map/)

The **Vermont Livability Map** is an open-source tool developed by VERSO-UVM to visualize critical datasets that influence the quality of life across Vermont. This interactive map aims to support policymakers, planners, researchers, and community members in making informed decisions related to zoning, infrastructure, and environmental resilience.

## Table of Contents
- [About](#about)
- [Features](#features)
- [Data Layers](#data-layers)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Contributing](#contributing)
- [License](#license)

## About
The Vermont Livability Map tells the story of the Vermont Zoning Atlas Project and combines data from the Vermont Zoning Atlas, the Wastewater Infrastructure Map, and a flood risk map to provide an educational exploration of how zoning and infrastructure affect livability in Vermont. It leverages open data and open-source technology to create an accessible resource that supports sustainable development, emergency preparedness, and policy analysis.

## Features
- **Zoning Visualization:** Explore data from the Vermont Zoning Atlas to understand zoning restrictions and opportunities across Vermont.
- **Infrastructure Mapping:** View wastewater infrastructure data, helping identify areas with or without access to critical services.
- **Flood Risk Assessment:** Analyze flood-prone regions to assist in resilience planning and to promote safe, sustainable development.
- **User-Friendly Interface:** Navigate Vermont’s diverse datasets in a streamlined, interactive format that simplifies complex information for easy interpretation.

## Data Layers
The following datasets are integrated into the Vermont Livability Map:
- **Vermont Zoning Atlas**: Provides insights into zoning policies across different municipalities in Vermont.
- **Wastewater Infrastructure Map**: Maps existing wastewater systems and locations in need of infrastructure upgrades.
- **Flooding Map**: Identifies flood risk areas to aid in climate adaptation and emergency preparedness.

## Getting Started
To get a local copy up and running, follow these instructions.

### Prerequisites
- **Node.js** and **npm**: Required for running the app locally.
- **Git**: Required for cloning the repository.

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/VERSO-UVM/Vermont-Livability-Map.git

### Build process

This app is built using Vue3 and Vite. Follow the steps below to build the app.

#### Recommended IDE Setup

[VSCode](https://code.visualstudio.com/) + [Volar](https://marketplace.visualstudio.com/items?itemName=Vue.volar) (and disable Vetur).

#### Customize configuration

See [Vite Configuration Reference](https://vite.dev/config/).

#### Project Setup

```sh
npm install
```

#### Compile and Hot-Reload for Development

```sh
npm run dev
```

#### Compile and Minify for Production

```sh
npm run build
```

### Contributing
Contributions are welcome! Please see our Contributing Guide for ways to get started.

* Fork the repository.
* Create your feature branch (git checkout -b feature/AmazingFeature).
* Commit your changes (git commit -m 'Add some AmazingFeature').
* Push to the branch (git push origin feature/AmazingFeature).
* Open a pull request.

### License
Distributed under the MIT License. See [LICENSE](LICENSE.md) for more information.



## TODO

- [x] add static maps showing multiple layers for monpelier
- [x] add qualtrax form
- [x] create diagram to show how different groups work together 
- [x] include note about unzoned blank districts
- [x] include note about beta map in progress
- [ ] filter out Overlay, Overlay not affecting use, and Unkown
- [x] add plus minuis icons to zoom in 
- [x] add citation for flood data in montpleier map 
- [ ] programmatic implementation of town specific zoning stats (x number of single zoned districts, etc)
