# Mock Tool
**[English below](https://github.com/phuongnam195/mock-tool#english-version)**

Công cụ hỗ trợ quản lý nhiều Mock API cùng [json_server](https://github.com/typicode/json-server)

## Cách dùng
1. Cài đặt [JSON Server](https://github.com/typicode/json-server)
2. Cài đặt [Mock Tool](https://github.com/phuongnam195/mock-tool/releases) hoặc chạy mã nguồn
3. Chạy Json Server: `json-server --host <địa chỉ IP wifi> --watch <tên file xuất>.json`
4. Mở Mock Tool, chọn thư mục xuất và nhập tên file xuất (.json)
5. Thêm tập Mock APIs (.json)
6. Sao chép đường dẫn các API (nút copy) để sử dụng

## Ví dụ:
1. File xuất: **data.json**
2. Các tập mock:
 - **first-api.json**
    ```json
    {
        "status-a": { "a": 1 },
        "status-b": { "b": 2 },
        "status-c": { "c": 3 }
    }
    ```
 - **second-api.json**
    ```json
    {
        "status-x": { "x": true },
        "status-y": { "y": false },
    }
    ```
3. Chọn ***first-api***/status-c và ***second-api***/status-x
4. Nội dung file xuất: 
 - **data.json**
    ```json
    {
        "first-api": { "c": 3 },
        "second-api": { "x": true }
    }
    ```

## Screenshot

![image](https://user-images.githubusercontent.com/90912187/185856942-50cb0a93-eb44-467f-be94-075693c5167c.png)
![image](https://user-images.githubusercontent.com/90912187/185856963-972cf7e2-d8ff-40a2-9650-6a397a637a52.png)

# English version

A small tool to manage multiple mock APIs with [json_server](https://github.com/typicode/json-server)

## How to use
1. Install [JSON Server](https://github.com/typicode/json-server)
2. Install [Mock Tool](https://github.com/phuongnam195/mock-tool/releases) or run source code
3. Run Json Server: `json-server --host <wifi ip address> --watch <export file name>.json`
4. Select export directory and enter the name of export file (.json)
5. Launch Mock Tool, and add mock sets (.json)
    - Suitable JSON format: **first-api.json**
    ```json
    {
        "status-a": {  },
        "status-b": {  },
        "status-c": {  }
    }
    ```
6. Copy API url (button) to use

## Example:
1. Export file: **data.json**
2. Mock sets:
 - **first-api.json**
    ```json
    {
        "status-a": { "a": 1 },
        "status-b": { "b": 2 },
        "status-c": { "c": 3 }
    }
    ```
 - **second-api.json**
    ```json
    {
        "status-x": { "x": true },
        "status-y": { "y": false },
    }
    ```
3. Select ***first-api***/status-c and ***second-api***/status-x
4. Export file's content: 
 - **data.json**
    ```json
    {
        "first-api": { "c": 3 },
        "second-api": { "x": true }
    }
    ```
