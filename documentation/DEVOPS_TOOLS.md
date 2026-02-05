# Devops Tools Comparison

## DevOps Essentials: The Big Four Tools

## Comparison Table

| Feature (特性) | Docker 🐳 | Ansible 📜 | Terraform 🏗️ | Kubernetes ☸️ |
| :--- | :--- | :--- | :--- | :--- |
| **Chinese Name**<br>中文名稱 | **Docker**<br>(容器) | **Ansible**<br>(配置管理) | **Terraform**<br>(基礎設施即程式碼) | **Kubernetes**<br>(容器編排) |
| **Role**<br>角色 | **The Package**<br>(打包員) | **The Furnisher**<br>(裝修工) | **The Builder**<br>(建築商) | **The Manager**<br>(管理者) |
| **Primary Goal**<br>主要目標 | Isolate App & Dependencies<br>隔離應用程式與依賴環境 | Configure Servers<br>配置伺服器內部環境 | Provision Infrastructure<br>建立基礎設施 (雲端資源) | Orchestrate Containers<br>管理與調度容器集群 |
| **Key Question**<br>關鍵問題 | "Does it run on my machine?"<br>"它能在我的機器上跑嗎？" | "Is the server set up correctly?"<br>"伺服器設定正確嗎？" | "Do the servers exist?"<br>"伺服器存在嗎？" | "Is the app healthy?"<br>"應用程式健康嗎？" |
| **Analogy**<br>比喻 | IKEA Furniture Box<br>宜家家具包裝盒 | Interior Designer<br>室內設計師 / 水電工 | Construction Crew<br>建築施工隊 | Hotel Management System<br>飯店管理系統 |
| **File Type**<br>檔案類型 | `Dockerfile` | `playbook.yml` | `main.tf` | `deployment.yaml` |

---

## The Analogy: Building a Hotel (概念比喻：蓋一家飯店)

To understand the difference, imagine we are building and running a massive hotel.
為了理解它們的區別，想像我們正在建造並營運一家大型飯店。

#### Terraform is "The Construction Crew" (建築施工隊)
* **Core Function:** Creates the Shell (建立空殼)
* **English:** You give them the blueprints. They pour the concrete, build the walls, install the plumbing, and connect the power lines. They build the *empty structure*.
* **繁體中文:** 你給他們藍圖。他們負責澆灌混凝土、砌牆、安裝水管和連接電力網。他們建造的是**空殼結構**（即伺服器或雲端資源）。

#### Ansible is "The Interior Designer" (室內設計師)
* **Core Function:** Prepares the Environment (準備環境)
* **English:** Once the building is up, it's empty. Ansible goes into every room to paint the walls, install the carpets, screw in the lightbulbs, and make sure the security system is on.
* **繁體中文:** 大樓建好後是空的。Ansible 進入每個房間粉刷牆壁、鋪設地毯、安裝燈泡，並確保保全系統已經開啟。

#### Docker is "The Standardized Guest Pod" (標準化客房艙)
* **Core Function:** Packages the Content (打包內容)
* **English:** Instead of guests bringing their own messy luggage, every guest arrives in a pre-packaged "Pod" that has exactly what they need. It looks exactly the same whether it's in Hotel A or Hotel B.
* **繁體中文:** 客人不需要帶自己亂七八糟的行李，而是每個人都住進一個預先打包好的「標準艙」，裡面有他們需要的一切（床、書桌、盥洗用具）。無論是在 A 飯店還是 B 飯店，這個艙看起來都一模一樣。

#### Kubernetes is "The Hotel Manager" (飯店大廳經理)
* **Core Function:** Manages the Operations (營運管理)
* **English:** The manager watches the hotel 24/7. If 500 guests arrive at once, the manager opens 5 new floors instantly. If a room's AC breaks, the manager moves the guest to a new room in 1 second.
* **繁體中文:** 經理全天候 24 小時監控飯店。如果突然來了 500 位客人，經理會立刻開放 5 個新樓層。如果某個房間冷氣壞了（容器崩潰），經理會在 1 秒鐘內把客人轉移到新房間。

---

## Summary Workflow (實際工作流程)

In a real-world scenario, the order of operations is usually:
這四者在實際工作中的執行順序通常如下：

1.  **Terraform**: Builds the servers (建立伺服器).
2.  **Ansible**: Installs Docker or K8s on those servers (在伺服器上安裝軟體環境).
3.  **Docker**: Packages the app into a portable image (將應用程式打包成映像檔).
4.  **Kubernetes**: Runs and scales the image across the cluster (在集群上運行並擴展應用).

---

## anology

| Tool (工具) | Your Concept (您的概念) | Core Function (核心功能) | Analogy (比喻) |
| --- | --- | --- | --- |
| **1. Terraform** | The Room Builder<br>

<br>(造房者)<br>

<br>Creates the "empty rooms".<br>

<br>建造出「空房間」。 | **Provisioning**<br>

<br>(基礎設施供應) | Construction Crew<br>

<br>(建築工班) 🏗️<br>

<br>負責把房子蓋好，接通水電，但裡面是空的 (Empty Room)。 |
| **2. Ansible** | The Organizer<br>

<br>(組織者)<br>

<br>Installs "facilities" (dependencies) to make the room usable.<br>

<br>進入房間安裝「設施」(軟體依賴)，讓房間可以住人。 | **Configuration**<br>

<br>(組態設定) | Interior Designer / Contractor<br>

<br>(室內設計師/裝修工頭) 🛠️<br>

<br>負責進場安裝瓦斯爐、馬桶，或是**Docker 引擎**。沒有他安裝這些「設施」，房間無法運作。 |
| **3. Docker** | The Package<br>

<br>(包裹)<br>

<br>Packed into the right rooms.<br>

<br>被放入合適房間的「軟體包裹」。 | **Packaging**<br>

<br>(封裝打包) | Sealed Parcel<br>

<br>(密封包裹) 📦<br>

<br>裡面裝著應用程式。它需要 Ansible 先把「桌子」或「引擎」裝好，這個包裹才有地方放、才能被打開使用。 |
| **4. Kubernetes** | The Manager<br>

<br>(管理者)<br>

<br>Decides which package goes to which room.<br>

<br>決定哪個包裹要去哪個房間。 | **Orchestration**<br>

<br>(編排調度) | Logistics Manager<br>

<br>(物流中心經理) ☸️<br>

<br>他不管房間怎麼蓋，也不管包裹裡裝什麼。他只負責看著大表，指揮：「把這 3 個包裹送到 101 號房！」 |

---

