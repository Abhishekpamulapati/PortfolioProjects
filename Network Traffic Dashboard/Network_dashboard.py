import streamlit as st
import pandas as pd
import plotly.express as px
import threading
import time
from datetime import datetime
from scapy.all import sniff, IP, TCP, UDP
import logging

# ---------------------- LOGGING ----------------------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ---------------- PACKET PROCESSOR ------------------
class PacketProcessor:
    def __init__(self):
        self.protocol_map = {1: "ICMP", 6: "TCP", 17: "UDP"}
        self.packet_data = []
        self.lock = threading.Lock()
        self.start_time = datetime.now()

    def get_protocol(self, proto_num):
        return self.protocol_map.get(proto_num, f"OTHER({proto_num})")

    def process_packet(self, packet):
        if IP not in packet:
            return

        with self.lock:
            pkt = {
                "timestamp": datetime.now(),
                "source": packet[IP].src,
                "destination": packet[IP].dst,
                "protocol": self.get_protocol(packet[IP].proto),
                "size": len(packet),
            }

            if TCP in packet:
                pkt["src_port"] = packet[TCP].sport
                pkt["dst_port"] = packet[TCP].dport
            elif UDP in packet:
                pkt["src_port"] = packet[UDP].sport
                pkt["dst_port"] = packet[UDP].dport

            self.packet_data.append(pkt)

            # Prevent memory blow-up
            if len(self.packet_data) > 5000:
                self.packet_data.pop(0)

    def get_dataframe(self):
        with self.lock:
            return pd.DataFrame(self.packet_data)

# ---------------- PACKET CAPTURE ------------------
def start_packet_capture():
    processor = PacketProcessor()

    def capture():
        sniff(prn=processor.process_packet, store=False)

    thread = threading.Thread(target=capture, daemon=True)
    thread.start()

    return processor

# ---------------- VISUALIZATIONS ------------------
def create_visualizations(df):
    if df.empty:
        st.info("Waiting for packets...")
        return

    # Protocol distribution
    fig_proto = px.pie(
        df,
        names="protocol",
        title="Protocol Distribution"
    )
    st.plotly_chart(fig_proto, use_container_width=True)

    # Packets per second
    df["timestamp"] = pd.to_datetime(df["timestamp"])
    pps = df.groupby(df["timestamp"].dt.floor("S")).size()

    fig_time = px.line(
        x=pps.index,
        y=pps.values,
        title="Packets per Second"
    )
    st.plotly_chart(fig_time, use_container_width=True)

    # Top source IPs
    top_sources = df["source"].value_counts().head(10)
    fig_src = px.bar(
        x=top_sources.index,
        y=top_sources.values,
        title="Top Source IPs"
    )
    st.plotly_chart(fig_src, use_container_width=True)

# ---------------- MAIN APP ------------------
def main():
    st.set_page_config(
        page_title="Network Traffic Analysis",
        layout="wide"
    )

    st.title("📡 Real-Time Network Traffic Analysis")

    if "processor" not in st.session_state:
        st.session_state.processor = start_packet_capture()
        st.session_state.start_time = time.time()

    processor = st.session_state.processor
    df = processor.get_dataframe()

    # Metrics
    col1, col2 = st.columns(2)
    col1.metric("Total Packets", len(df))
    col2.metric(
        "Capture Duration (s)",
        f"{time.time() - st.session_state.start_time:.1f}"
    )

    # Charts
    create_visualizations(df)

    # Recent packets
    st.subheader("Recent Packets")
    if not df.empty:
        st.dataframe(
            df.tail(10),
            use_container_width=True
        )

    # Auto refresh every 2 seconds
    st.autorefresh(interval=2000, key="refresh")

# ---------------- RUN ------------------
if __name__ == "__main__":
    main()
